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
- [research/maintenance-dashboard.md](maintenance-dashboard.md)
  自动刷新的维护运营面板
- [research/ops-today.md](ops-today.md)
  自动刷新的今日维护摘要
- [research/outreach-playbook.md](outreach-playbook.md)
  外链留言投放手册
- [research/outreach-tracking-board.md](outreach-tracking-board.md)
  外链留言追踪表
- [research/daily/README.md](daily/README.md)
  日更记录说明
- [research/weekly/README.md](weekly/README.md)
  周汇总说明
- [research/templates/daily-check-template.md](templates/daily-check-template.md)
  每日检查模板
- [research/templates/candidate-review-template.md](templates/candidate-review-template.md)
  单机场观察模板
- [research/templates/weekly-summary-template.md](templates/weekly-summary-template.md)
  每周汇总模板

## 每天维护建议顺序

1. 打开二毛总页和已跟踪候选官网
2. 记录有没有实质变化
3. 更新 [candidate-status-board.md](candidate-status-board.md)
4. 把当天变化写进 `research/daily/YYYY-MM-DD.md`
5. 只有出现实质变化时，再决定是否改公开页
6. 每周末把这一周的关键变化收拢到 `research/weekly/YYYY-Www.md`
7. 维护结束前跑一次健康检查，确认三层已经串起来

## 自动化入口

- 本地生成：`scripts/create-daily-check.sh`
- 本地周汇总：`scripts/create-weekly-summary.sh`
- 总页联动刷新：`scripts/sync-status-overview.sh`
- 维护健康检查：`scripts/check-maintenance-health.sh`
- 一步收口：`scripts/run-maintenance-closeout.sh`
- 运营面板刷新：`scripts/update-maintenance-dashboard.sh`
- 今日摘要刷新：`scripts/update-ops-summary.sh`
- GitLab 自动维护入口：`scripts/run-gitlab-maintenance-task.sh`
- 仓库定时任务：`.github/workflows/daily-maintenance.yml`
- 仓库周汇总任务：`.github/workflows/weekly-summary.yml`
- 总页联动同步任务：`.github/workflows/status-overview-sync.yml`
- 每日晚间收口检查：`.github/workflows/maintenance-closeout.yml`
- GitLab 计划任务配置说明：`research/gitlab-automation-setup.md`
- 每天北京时间 `09:30` 会自动创建当天的内部检查页
- 每周日北京时间 `10:15` 会自动创建当周汇总页
- 当候选状态总表或重点详情页进入 `main` 后，会自动尝试同步总页联动总览
- 每天北京时间 `22:45` 会自动执行一次维护收口检查，并把检查结果写进 Actions 摘要
- 也可以在 GitHub Actions 里手动触发，并补生成指定日期的记录

GitLab 这一侧现在也已经接上：

- 根目录新增 `.gitlab-ci.yml`
- 可以在 GitLab `Build > Pipeline schedules` 里用 `Inputs` 创建日更 / 周汇总 / 晚间收口 3 条计划任务
- GitLab 回推需要先打开 `Settings > CI/CD > Job token permissions > Allow Git push requests to the repository`
- `research/ops-today.md` 会随日更 / 周汇总 / 晚间收口一起自动刷新，帮你快速判断今天是否需要人工介入

这套自动化目前包含两类能力：

- 自动创建内部研究层的日更记录和周汇总骨架
- 半自动刷新公开总页里的状态联动总览
- 辅助检查日更、状态总表和总页联动总览是否已经串起来
- 把“刷新总页联动 + 健康检查”合成一个可手动 / 定时执行的收口动作
- 自动输出固定 Markdown 运营面板，集中展示过期候选、待同步项和待建页提醒
- 自动输出一个更短的“今日维护摘要”页，方便打开仓库就判断今天要不要人工介入
- 自动在每日日更骨架里带出“今日建议优先复查 Top 3”，减少人工翻总表的时间

其中总页联动刷新仍建议在你确认详情页和候选状态总表都更新后，再手动运行一次。

## 这里和公开页的关系

- `research/`：内部研究、观察、草稿、状态记录
- `docs/recommendations/`：公开对外内容

简单理解就是：

- 内部层可以每天都更
- 公开层只在有价值变化时更新
