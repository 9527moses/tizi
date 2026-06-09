# 外链留言投放手册

更新日期：2026-06-09

这份手册不是让我们去批量刷链接，而是让外链动作更像 `精准答疑`。

原则只有 4 条：

1. 先回答问题，再决定要不要留链接
2. 一条回复只放 `1 个` 最贴题的页面
3. 优先放 `排障页 / 场景页 / 对比页`，不要老丢首页
4. 如果平台版规不允许自我推广，就不留链接

## 1. GitHub 去哪里找可留言的帖子

优先级从高到低：

- 和代理、翻墙、OpenClash、Hiddify、ChatGPT 访问相关仓库的 `Discussions`
- 相关客户端仓库里的 `Issues`
- 明确在问 `iPhone 已连接但不通`、`订阅导入失败`、`ChatGPT 转圈` 的评论串
- 设备、路由器、OpenWrt、Clash Meta、Hiddify 相关的文档讨论区

不建议去的地方：

- 无关项目的 issue 区
- 别人的仓库首页、README 评论区
- 已经明显在清理广告的讨论串

### GitHub 常见问题 -> 对应页面

| 遇到的问题 | 优先配页 | 备用页 |
|---|---|---|
| iPhone 显示已连接但打不开 | `docs/recommendations/iphone-vpn-connected-but-not-working.md` | `docs/recommendations/iphone-cross-border-recommendations.md` |
| OpenClash 导入订阅失败 | `docs/recommendations/openclash-subscription-import-failed.md` | `docs/recommendations/router-airport-recommendations.md` |
| ChatGPT 一直转圈 | `docs/recommendations/chatgpt-loading-forever-fix.md` | `docs/recommendations/chatgpt-airport-recommendations.md` |
| 第一次买机场怎么选 | `docs/recommendations/beginner-airport-recommendations.md` | `docs/recommendations/first-airport-recommendation-which-to-buy.md` |
| 机场和 VPN 怎么选 | `docs/recommendations/airport-vs-vpn-for-beginners.md` | `docs/recommendations/vpn-alternatives-recommendations.md` |

## 2. GitLab 去哪里找可留言的帖子

优先级从高到低：

- 相关项目的 `Issue` 讨论
- 文档仓库里的 `How to`、`Setup help`、`Troubleshooting` 讨论串
- 和 OpenClash、订阅导入、路由器配置、客户端兼容相关的问题串

不建议去的地方：

- 和代理、网络、客户端无关的项目
- 纯功能迭代、代码 review、合并请求争论区

### GitLab 常见问题 -> 对应页面

| 遇到的问题 | 优先配页 | 备用页 |
|---|---|---|
| 路由器 / 全屋代理怎么选 | `docs/recommendations/router-airport-recommendations.md` | `docs/recommendations/openclash-airport-recommendations.md` |
| Hiddify 和 OpenClash 怎么选 | `docs/recommendations/hiddify-vs-openclash.md` | `docs/recommendations/router-airport-subscription-compatibility.md` |
| 订阅兼容性不稳 | `docs/recommendations/router-airport-subscription-compatibility.md` | `docs/recommendations/openclash-subscription-import-failed.md` |
| 电脑端第一次怎么配 | `docs/recommendations/computer-cross-border-recommendations.md` | `docs/recommendations/windows-cross-border-recommendations.md` |
| Mac / iPhone 首次上手 | `docs/recommendations/macos-cross-border-recommendations.md` | `docs/recommendations/iphone-cross-border-recommendations.md` |

## 3. Reddit 去哪里找可留言的帖子

优先级从高到低：

- `VPN alternatives`、`AI access`、`OpenClash / router setup` 相关问题帖
- `Which one should I choose`、`is this worth it`、`how to fix` 这类求助帖
- 已经有人在楼里认真回答，讨论氛围正常的帖子

不建议去的地方：

- 明确写了 `no self-promo`
- 明显在吵架或政治话题串里
- 新号第一次发言就带链接

### Reddit 常见问题 -> 对应页面

| 遇到的问题 | 优先配页 | 备用页 |
|---|---|---|
| ChatGPT / AI access unstable | `docs/recommendations/chatgpt-airport-recommendations.md` | `docs/recommendations/chatgpt-airport-stability-checklist.md` |
| Cheap vs stable | `docs/recommendations/cheap-vs-stable-airport-recommendations.md` | `docs/recommendations/cheap-airport-recommendations-worth-it.md` |
| Monthly vs yearly plan | `docs/recommendations/airport-monthly-vs-yearly-plans.md` | `docs/recommendations/airport-plan-selection-guide.md` |
| Trial before buying | `docs/recommendations/airport-trial-before-buying-guide.md` | `docs/recommendations/airport-trial-recommendations.md` |
| Ranking list is confusing | `docs/recommendations/airport-ranking-lists-trustworthy.md` | `docs/recommendations/airport-guide-2026.md` |

## 4. V2EX 去哪里找可留言的帖子

优先级从高到低：

- `问与答`
- `程序员`
- `宽带症候群`
- `分享发现` 里真正有人提到翻墙、机场、路由器、OpenClash、ChatGPT 访问的问题帖

不建议去的地方：

- 已经明显有人在反感广告的帖子
- 纯资源贴、纯广告贴下面抢楼
- 明显更适合用一两句回答完、不需要链接的贴

### V2EX 常见问题 -> 对应页面

| 遇到的问题 | 优先配页 | 备用页 |
|---|---|---|
| iPhone / Mac 怎么少踩坑 | `docs/recommendations/iphone-cross-border-recommendations.md` | `docs/recommendations/macos-cross-border-recommendations.md` |
| 家里多设备怎么选 | `docs/recommendations/home-cross-border-recommendations.md` | `docs/recommendations/router-airport-recommendations.md` |
| ChatGPT 怎么稳一点 | `docs/recommendations/chatgpt-airport-recommendations.md` | `docs/recommendations/chatgpt-loading-forever-fix.md` |
| 便宜机场值不值 | `docs/recommendations/cheap-airport-recommendations-worth-it.md` | `docs/recommendations/stable-airport-recommendations-how-to-choose.md` |
| 排障总入口 | `docs/recommendations/troubleshooting-hub.md` | `docs/recommendations/airport-guide-2026.md` |

## 5. 留完以后怎么记表

每次留言后，至少记录这 10 项：

| 字段 | 说明 |
|---|---|
| 日期 | 留言日期 |
| 平台 | GitHub / GitLab / Reddit / V2EX |
| 话题类型 | 新手 / ChatGPT / 路由器 / 设备 / 排障 / 套餐 |
| 帖子标题 | 原帖标题或讨论主题 |
| 帖子链接 | 留言所在链接 |
| 我们放的页面 | 实际外链页 |
| 留言方式 | 评论 / 回复 / Discussion / Issue |
| 是否带链接 | 是 / 否 |
| 7 天结果 | 是否有点击、回复、收藏、被删 |
| 备注 | 比如“版规严格”“楼主有回”“后续可复投” |

## 6. 7 天后看什么

留言不是发完就算，7 天后至少回看一次：

- 有没有被删
- 有没有人继续回复
- 有没有被点踩、被喷广告
- 有没有把人带到更深页
- 有没有同类问题值得做成新页面

如果满足下面任一条，可以判定为有效：

- 对方继续追问，说明内容命中了问题
- 留言没被删，且有人顺着讨论
- 我们发现这个问题反复出现，值得做成新页

## 7. 怎么看“带来的收录效果”

不要把“留了一条评论”直接理解成“SEO 立刻涨”。

更适合看的，是这几类间接信号：

- 被外链的页面，后面是否更频繁被补充和更新
- 这类页面是否慢慢变成仓库里更核心的入口
- 同类问题是否越来越集中到同一批页面
- 公开页内部链接是否因为这些讨论而越做越强

如果你们后面接统计工具，可以再补：

- 页面访问量
- 外部来源访问
- 停留时间
- 二跳页面

在没接统计前，先用人工结果代替：

- 有无回复
- 有无收藏 / star / follow-up
- 有无引出新的问题页

## 8. 最后记住

- 一天 1 到 3 条高质量留言，远比 20 条模板群发更有效
- 能不留链接也能回答清楚，才有资格留链接
- 优先把外链当成 `用户研究`，不是单纯当发广告
