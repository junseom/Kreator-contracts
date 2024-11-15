// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Kreator is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    // 권리 요청 구조체
    struct ViewRequest {
        address requester;
        bool approved;
    }

    // 토큰별 권리 요청 정보 저장
    mapping(uint256 => ViewRequest[]) public viewRequests;

    // NFT 가격 저장
    mapping(uint256 => uint256) public tokenPrices;

    // 수익금 전송 주소 목록
    address[3] public payoutAddresses;

    // NFT 판매 수익금 저장
    mapping(uint256 => uint256) public salesProceeds;

    // 이벤트 선언
    event NFTCreated(uint256 tokenId, address creator, string tokenURI);
    event ViewRequested(uint256 tokenId, address requester);
    event ViewRequestApproved(uint256 tokenId, address requester);
    event NFTPurchased(uint256 tokenId, address buyer, uint256 price);
    event PayoutSent(uint256 tokenId, uint256 payoutAmount, address payoutAddress);

    constructor(address[3] memory initialPayoutAddresses) ERC721("Kreator", "KRT") {
        payoutAddresses = initialPayoutAddresses;
    }

    // NFT 생성 함수
    function createNFT(string memory tokenURI, uint256 price) public returns (uint256) {
        // 새로운 토큰 ID 할당
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;

        // NFT 발행
        _mint(msg.sender, tokenId);

        // 토큰에 메타데이터 연결
        _setTokenURI(tokenId, tokenURI);

        // 가격 설정
        tokenPrices[tokenId] = price;

        // 이벤트 트리거
        emit NFTCreated(tokenId, msg.sender, tokenURI);

        return tokenId;
    }

    // 뷰 요청 등록 함수
    function requestView(uint256 tokenId) public {
        require(_exists(tokenId), "Token does not exist");
        viewRequests[tokenId].push(ViewRequest(msg.sender, false));
        emit ViewRequested(tokenId, msg.sender);
    }

    // 뷰 요청 승인 함수
    function approveViewRequest(uint256 tokenId, address requester) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can approve view requests");
        ViewRequest[] storage requests = viewRequests[tokenId];
        bool found = false;
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].requester == requester && !requests[i].approved) {
                requests[i].approved = true;
                found = true;
                emit ViewRequestApproved(tokenId, requester);
                break;
            }
        }
        require(found, "No pending request found for this requester");
    }

    // 특정 사용자가 뷰 권한이 있는지 확인
    function hasViewAccess(uint256 tokenId, address user) public view returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        ViewRequest[] storage requests = viewRequests[tokenId];
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].requester == user && requests[i].approved) {
                return true;
            }
        }
        return false;
    }

    // 특정 팬아트에 대해 뷰 권한이 있는 모든 사용자 조회
    function getViewAccessList(uint256 tokenId) public view returns (address[] memory) {
        require(_exists(tokenId), "Token does not exist");
        ViewRequest[] storage requests = viewRequests[tokenId];
        uint256 count = 0;

        // 승인된 요청 수 계산
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].approved) {
                count++;
            }
        }

        // 승인된 사용자 주소 배열 생성
        address[] memory approvedUsers = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].approved) {
                approvedUsers[index] = requests[i].requester;
                index++;
            }
        }

        return approvedUsers;
    }

    // 뷰 권한이 있는 사용자만 NFT 구매 가능
    function purchaseNFT(uint256 tokenId) public payable {
        require(_exists(tokenId), "Token does not exist");
        require(hasViewAccess(tokenId, msg.sender), "You do not have view access to this NFT");
        require(msg.value >= tokenPrices[tokenId], "Insufficient payment");

        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != msg.sender, "You already own this NFT");

        // 소유권 이전
        _transfer(tokenOwner, msg.sender, tokenId);

        // 수익금 저장
        salesProceeds[tokenId] += msg.value;

        // 이벤트 트리거
        emit NFTPurchased(tokenId, msg.sender, msg.value);
    }

    // 판매자가 수익금 전송
    function payoutSales(uint256 tokenId, uint8 payoutIndex) public {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Only the owner can payout sales proceeds");
        require(salesProceeds[tokenId] > 0, "No proceeds available for payout");
        require(payoutIndex < payoutAddresses.length, "Invalid payout index");

        uint256 amount = salesProceeds[tokenId];
        salesProceeds[tokenId] = 0;

        address payoutAddress = payoutAddresses[payoutIndex];
        payable(payoutAddress).transfer(amount);

        // 이벤트 트리거
        emit PayoutSent(tokenId, amount, payoutAddress);
    }

    // 컨트랙트 소유자만 실행할 수 있는 함수: 로열티 기능 추가 등을 위해
    function adminFunction() public onlyOwner {
        // 관리자 권한 기능 추가 가능
    }
}
