#todo 你的建表语句,包含索引
--{month_suffix}：对应年月例如202401、202402等
CREATE TABLE `order_{month_suffix}` (
                         `id` varchar(32) NOT NULL COMMENT '订单号',
                         `user_id` varchar(32) NOT NULL COMMENT '买家ID',
                         `seller_id` varchar(32) NOT NULL COMMENT '卖家ID',
                         `sku_id` varchar(32) NOT NULL COMMENT 'skuId',
                         `amount` int(11) NOT NULL COMMENT '购买数量',
                         `money` decimal(18,2) NOT NULL COMMENT '购买金额',
                         `pay_time` datetime DEFAULT NULL COMMENT '购买时间',
                         `pay_status` varchar(1) NOT NULL COMMENT '支付状态（NEW 未支付订单,PAY已经支付订单,CANCEL超时取消订单）',
                         `del_flag` tinyint(1) NOT NULL COMMENT '删除标志（0代表存在 1代表删除）',
                         `create_by` varchar(100) NOT NULL COMMENT '创建人',
                         `create_time` datetime NOT NULL COMMENT '创建时间',
                         `update_by` varchar(100) DEFAULT NULL COMMENT '修改人',
                         `update_time` datetime DEFAULT NULL COMMENT '修改时间',
                         `pay_type` varchar(64) NOT NULL COMMENT '支付类型，微信-银行-支付宝',
                         `nickname` varchar(64) DEFAULT NULL COMMENT '昵称',
                         `head_img` varchar(524) DEFAULT NULL COMMENT '头像',
                         `order_type` varchar(32) DEFAULT NULL COMMENT '订单类型 DAILY普通单，PROMOTION促销订单',
                         `receiver_address` varchar(1024) DEFAULT NULL COMMENT '收货地址 json存储',
                         PRIMARY KEY (`id`),
                         KEY `IDX_SELLER_ID` (`seller_id`) USING BTREE COMMENT '卖家ID索引',
                         KEY `IDX_USER_ID` (`user_id`) USING BTREE COMMENT '买家ID索引',
                         KEY `IDX_CREATE_TIME` (`create_time`) USING BTREE COMMENT '创建时间索引',
                         KEY `IDX_PAYINFO` (`pay_status`,`pay_time`,`money`) USING BTREE COMMENT '支付相关索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

--主要的查询场景包括买卖家频繁查询"我的订单",所以建立了卖家ID索引、买家ID索引、支付相关索引并且在create_time也创建了索引便于日期范围数据查询
--鉴于近期订单量级2000W且不考虑增长，在此背景数据量级下，使用分表技术即可满足此场景需求，框架使用shardingSphere
--分表键使用createTime 字段，按月分表可以有效地管理数据的增长，并且可以根据订单创建时间快速定位到具体的分表。
--如果读写压力大，可以使用mysql主从分离，1主1从（主库负责写入，同步到从库中从库负责读即可）

