# GitLab 每日自动化设置

更新日期：2026-06-07

这页是给这个 GitLab 仓库用的后台设置说明。

仓库里的自动化代码已经放好：

- [.gitlab-ci.yml](../.gitlab-ci.yml)
- [scripts/run-gitlab-maintenance-task.sh](../scripts/run-gitlab-maintenance-task.sh)

GitLab 现在推荐在计划任务里直接用 `Inputs`，而不是老的计划任务变量。

你后面要做的，主要就是在 GitLab 后台把计划任务和回推权限打开。

## 先开回推权限

这一步最关键，不开的话，流水线能生成文件，但推不回仓库。

在 GitLab 项目里打开：

1. `Settings > CI/CD`
2. 展开 `Job token permissions`
3. 打开 `Allow Git push requests to the repository`
4. 保存

这一步对应 GitLab 官方文档里的同项目 job token 回推能力。

## 建议建立的 3 个计划任务

打开：

1. `Build > Pipeline schedules`
2. 点 `New schedule`

然后按下面这样建。

### 1. Daily maintenance refresh

- Description: `Daily maintenance refresh`
- Interval Pattern: `35 9 * * *`
- 时区：`Asia/Shanghai`
- Target branch: `main`

Inputs:

- `maintenance-task` = `daily`
- `target-date` = 留空
- `max-stale-days` = `3`

这条会做：

- 自动创建当天的 `research/daily/YYYY-MM-DD.md`
- 自动刷新总页状态联动表
- 自动刷新 `research/maintenance-dashboard.md`
- 自动刷新 `research/ops-today.md`
- 有变化时自动提交回仓库

对应北京时间：`每天 09:35`

### 2. Weekly summary refresh

- Description: `Weekly summary refresh`
- Interval Pattern: `20 10 * * 0`
- 时区：`Asia/Shanghai`
- Target branch: `main`

Inputs:

- `maintenance-task` = `weekly`
- `target-date` = 留空
- `max-stale-days` = `3`

这条会做：

- 自动生成当周的 `research/weekly/YYYY-Www.md`
- 自动刷新 `research/ops-today.md`

对应北京时间：`每周日 10:20`

### 3. Maintenance closeout

- Description: `Maintenance closeout`
- Interval Pattern: `45 22 * * *`
- 时区：`Asia/Shanghai`
- Target branch: `main`

Inputs:

- `maintenance-task` = `closeout`
- `target-date` = 留空
- `max-stale-days` = `3`

这条会做：

- 自动跑一遍收口检查
- 自动刷新状态联动和维护面板
- 自动刷新 `research/ops-today.md`
- 产出 `maintenance-closeout-report.md` 作为流水线产物
- 如果还有超期未复查、缺失日更或待同步项，会把流水线标红

对应北京时间：`每天 22:45`

如果你的 GitLab 页面里没有单独的时区选项，而是默认按 UTC 解释 cron，再改用下面这组值：

- Daily maintenance refresh：`35 1 * * *`
- Weekly summary refresh：`20 2 * * 0`
- Maintenance closeout：`45 14 * * *`

## 如果你想手动跑一次

你可以直接在 GitLab 里手动跑：

1. 打开 `Build > Pipelines`
2. 点 `Run pipeline`
3. Branch 选 `main`
4. 直接填写 Inputs

常用手动输入：

- `maintenance-task` = `daily`
- `maintenance-task` = `sync`
- `maintenance-task` = `closeout`

可选输入：

- `target-date` = `2026-06-07`
- `max-stale-days` = `3`

其中：

- `daily`：补当天日更并刷新面板
- `sync`：只刷新总页联动和维护面板
- `closeout`：跑晚间收口检查

## 这套 GitLab 自动化现在包含什么

- 日更骨架自动创建
- 周汇总骨架自动创建
- 总页状态联动自动刷新
- 维护运营面板自动刷新
- 今日维护摘要自动刷新
- 晚间收口检查自动执行

## 需要知道的限制

- 公开推荐页不会“自动写新内容”，它只会自动刷新骨架、联动表和维护面板
- 真正的推荐结论、候选状态变化和新内容补页，还是需要你或我来判断后再改
- 计划任务是按 `schedule owner` 的权限执行的，如果这个用户后面失效，计划任务会停，需要在 GitLab 里 `Take ownership`
