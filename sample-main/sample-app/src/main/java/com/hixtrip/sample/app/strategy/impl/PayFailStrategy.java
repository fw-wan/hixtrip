package com.hixtrip.sample.app.strategy.impl;

import com.hixtrip.sample.app.strategy.PayCallbackStrategy;
import com.hixtrip.sample.client.order.vo.PayCallbaskVO;
import com.hixtrip.sample.domain.inventory.InventoryDomainService;
import com.hixtrip.sample.domain.inventory.conf.InventoryConf;
import com.hixtrip.sample.domain.inventory.model.Inventory;
import com.hixtrip.sample.domain.order.OrderDomainService;
import com.hixtrip.sample.domain.order.model.Order;
import com.hixtrip.sample.domain.pay.model.CommandPay;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component("payFailStrategy")
public class PayFailStrategy implements PayCallbackStrategy {
    @Autowired
    private OrderDomainService orderDomainService;
    @Autowired
    private InventoryDomainService inventoryDomainService;

    @Override
    public PayCallbaskVO payCallback(CommandPay commandPay) {
        Order order = orderDomainService.getOrderById(commandPay.getOrderId());
        if (order != null) {
            //更新订单
            Boolean aBoolean = orderDomainService.orderPayFail(commandPay);
            //释放预占用库存
            if (aBoolean) {
                Inventory inventory = inventoryDomainService.getInventory(order.getSkuId());
                inventoryDomainService.changeInventory(inventory, InventoryConf.RELEASE_HOLDING, order.getAmount());
                return PayCallbaskVO.builder().id(order.getId()).resultStatus("success").resultMsg("").build();
            }
        }
        return PayCallbaskVO.builder().id(order.getId()).resultStatus("error").resultMsg("").build();
    }
}
