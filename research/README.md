# 每日维护机制

更新日期：2026-06-07

这个目录是仓库的内部研究层，不直接面向公开推荐页。

它的目标是：

- 记录每天检查到了什么变化
- 把第三方来源、官网变化、候选状态变化沉淀下来
- 为公开页更新提供依据

## 目录结构

- [research/airport-review-framework.md](airport-review-framework.md)
  统一评测框架
- [research/airport-candidate-watchlist.md](airport-candidate-watchlist.md)
  候选机场总名单
- [research/public-update-rules.md](public-update-rules.md)
  公开页更新规则
- [research/candidate-status-board.md](candidate-status-board.md)
  候选状态总表
- [research/daily/README.md](daily/README.md)
  日更记录说明
- [research/templates/daily-check-template.md](templates/daily-check-template.md)
  每日检查模板
- [research/templates/candidate-review-template.md](templates/candidate-review-template.md)
  单机场观察模板

## 每天维护建议顺序

1. 打开二毛总页和已跟踪候选官网
2. 记录有没有实质变化
3. 更新 [candidate-status-board.md](candidate-status-board.md)
4. 把当天变化写进 `research/daily/YYYY-MM-DD.md`
5. 只有出现实质变化时，再决定是否改公开页

## 自动化入口

- 本地生成：`scripts/create-daily-check.sh`
- 仓库定时任务：`.github/workflows/daily-maintenance.yml`
- 每天北京时间 `09:30` 会自动创建当天的内部检查页
- 也可以在 GitHub Actions 里手动触发，并补生成指定日期的记录

这套自动化只负责创建内部研究层的日更记录，不会自动改公开推荐页。

## 这里和公开页的关系

- `research/`：内部研究、观察、草稿、状态记录
- `docs/recommendations/`：公开对外内容

简单理解就是：

- 内部层可以每天都更
- 公开层只在有价值变化时更新
