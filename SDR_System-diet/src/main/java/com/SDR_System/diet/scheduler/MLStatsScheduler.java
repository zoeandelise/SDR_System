package com.SDR_System.diet.scheduler;

import com.SDR_System.diet.service.MLDataService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * ML统计定时任务
 * 
 * @author SDR_System
 * @date 2025-10-10
 */
@Component
public class MLStatsScheduler {
    
    private static final Logger logger = LoggerFactory.getLogger(MLStatsScheduler.class);
    
    @Autowired
    private MLDataService mlDataService;
    
    /**
     * 每小时更新服务状态
     * 每小时的第0分钟执行
     */
    @Scheduled(cron = "0 0 * * * ?")
    public void updateServiceStatus() {
        try {
            logger.info("开始执行定时任务：更新ML服务状态");
            mlDataService.checkAndUpdateServiceStatus();
            logger.info("ML服务状态更新完成");
        } catch (Exception e) {
            logger.error("更新ML服务状态失败", e);
        }
    }
    
    /**
     * 每天凌晨2点聚合昨日推荐统计
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void aggregateDailyStats() {
        try {
            logger.info("开始执行定时任务：聚合昨日推荐统计");
            mlDataService.aggregateYesterdayStats();
            logger.info("昨日推荐统计聚合完成");
        } catch (Exception e) {
            logger.error("聚合昨日统计失败", e);
        }
    }
    
    /**
     * 每10分钟检查并更新服务状态（用于实时监控）
     */
    @Scheduled(cron = "0 */10 * * * ?")
    public void quickStatusCheck() {
        try {
            mlDataService.checkAndUpdateServiceStatus();
        } catch (Exception e) {
            logger.debug("快速状态检查失败", e);
        }
    }
}

