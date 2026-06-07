# 维护看板

更新日期：2026-06-07

这页不是公开内容，而是每天维护时的内部收口页。

它的作用很简单：帮助我们快速确认三层有没有串起来。

- `research/daily/`：今天有没有形成日更记录
- `research/candidate-status-board.md`：候选状态有没有跟着更新
- `docs/recommendations/airport-guide-2026.md`：总页联动总览有没有刷新

## 建议每天最后做的 3 步

1. 补完当天的 `research/daily/YYYY-MM-DD.md`
2. 同步更新 `research/candidate-status-board.md`
3. 运行：
   `scripts/check-maintenance-health.sh`

如果健康检查里还有待同步项，再继续跑：

- `scripts/sync-status-overview.sh`

## 我们主要看什么

- 今天的日更记录有没有缺失
- 哪些候选最近检查时间已经超过 3 天
- 总页联动表里有没有 `待同步` 或 `待建页`

## 推荐用法

- 日常维护结束后，先跑一次健康检查
- 如果看到过期项，优先补候选状态总表
- 如果看到 `待同步`，优先刷新总页联动总览
- 每周做周汇总前，也建议先跑一次
