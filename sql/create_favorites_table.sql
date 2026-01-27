-- 创建收藏夹表
CREATE TABLE IF NOT EXISTS diet_favorites (
    favorite_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    user_id bigint(20) NOT NULL COMMENT '用户ID',
    favorite_type varchar(20) NOT NULL COMMENT '收藏类型：food(食物), recipe(食谱), recommendation(推荐方案)',
    target_id bigint(20) NOT NULL COMMENT '目标ID（食物ID、食谱ID或推荐方案ID）',
    target_name varchar(200) NOT NULL COMMENT '目标名称',
    target_description text COMMENT '目标描述',
    target_image varchar(500) COMMENT '目标图片URL',
    create_time datetime NOT NULL COMMENT '创建时间',
    create_by varchar(64) COMMENT '创建者',
    update_time datetime COMMENT '更新时间',
    update_by varchar(64) COMMENT '更新者',
    remark varchar(500) COMMENT '备注',
    PRIMARY KEY (favorite_id),
    KEY idx_user_id (user_id),
    KEY idx_type_target (favorite_type, target_id),
    UNIQUE KEY uk_user_type_target (user_id, favorite_type, target_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='饮食收藏夹表';

-- 插入测试数据
INSERT INTO diet_favorites (user_id, favorite_type, target_id, target_name, target_description, create_time, create_by) 
VALUES 
(1, 'food', 1, '苹果', '新鲜红苹果，富含维生素C', NOW(), 'admin'),
(1, 'food', 2, '香蕉', '香甜的香蕉，富含钾元素', NOW(), 'admin'),
(1, 'recipe', 1, '健康早餐食谱', '营养均衡的早餐搭配方案', NOW(), 'admin');
