// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GoodsStore is Ownable {
    struct Goods {
        string name;
        uint256 price;
        uint256 stock;
    }

    mapping(uint256 => Goods) public goods;

    event GoodsAdded(uint256 goodsId, string name, uint256 price, uint256 stock);
    event GoodsPurchased(uint256 goodsId, address buyer, uint256 quantity, uint256 totalPrice);

    // 굿즈 등록 함수
    function addGoods(uint256 goodsId, string memory name, uint256 price, uint256 stock) public onlyOwner {
        require(goods[goodsId].price == 0, "Goods already exists");
        goods[goodsId] = Goods({
            name: name,
            price: price,
            stock: stock
        });
        emit GoodsAdded(goodsId, name, price, stock);
    }

    // 굿즈 구매 함수
    function purchaseGoods(uint256 goodsId, uint256 quantity) public payable {
        Goods storage item = goods[goodsId];
        require(item.price > 0, "Goods does not exist");
        require(item.stock >= quantity, "Not enough stock");
        uint256 totalPrice = item.price * quantity;
        require(msg.value >= totalPrice, "Insufficient payment");

        // 재고 차감
        item.stock -= quantity;

        // 소유자에게 금액 전송
        payable(owner()).transfer(totalPrice);

        // 이벤트 트리거
        emit GoodsPurchased(goodsId, msg.sender, quantity, totalPrice);

        // 잔액 환불
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }
}
