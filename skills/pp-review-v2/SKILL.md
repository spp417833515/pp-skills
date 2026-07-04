---
name: pp-review-v2
description: 审查 + 回顾 v2(合一)。成果审查 = 对每个子任务做 hostile 自我攻击,映射到 v05 四审 review_subtask_check(代码审查/测试/目的验收/复用审查)逐关 passed → finish_subtask 封口 → 父任务 set_final_acceptance 统一验收。任务回顾 = 读 task workflow_get 状态机盘点近期任务。--recap 只回顾不审。结论进引擎字段(四审 note + final_acceptance.report_md),不写游离 md。
disable-model-invocation: true
---

# /pp-review-v2 — 审查 + 回顾(5 维攻击 → 四审封口)

## 定位

```
本体 · 成果审查  对每个子任务做 hostile 自我攻击 → 映射 v05 四审(逐关 passed)→ 封口
附加 · 任务回顾  读 workflow_get 状态机盘点近期任务(独立模块 · 删 §三不影响审查本体)
不是 LLM 夸自己干得好 · 是切 hostile reviewer 找漏洞
审查结论必落引擎字段(四审 note/result + final_acceptance.report_md)· 不口头略过
```

## 调用方式

```
/pp-review-v2 <任务名/task_id>   审查本任务全子任务 + 末尾附近期回顾
/pp-review-v2 --recap            只回顾近期任务进度(不审代码)
```

## 接口契约(移植先看这 · 三段式见 /pp-pipeline §五)

| 项 | 内容 |
|---|---|
| 输入 | `task --workflow_get`:全子任务(execute 的 implementation/output + test_check)+ entries[].acceptance(v5) |
| 输出 | 四审 `review_subtask_check` 逐关 passed + `finish_subtask` 封口 + `set_final_acceptance`(report_md) |
| Store 接线 | ppwiki task v05 四审 · workflow_get 驱动 → 见 §Store 接线 |
| 缺依赖行为 | 无 ppwiki → 审查结论落本地报告(标「未入库」)· 修复闭环照走;附加模块 §三 跳过 |

## 一、自我攻击审查(5 维找茬 → 映射四审四关)

```
切换角色 = hostile reviewer · 默认"代码有问题" · 逐维举证驳倒 · 结论落对应四审关
```

**维0 · 目的达成(前置硬门 · 红线4 用户目的=硬标准)→ 四审 `purpose_acceptance`**:对照 clarify entries[].acceptance(v5 条目级)「预期效果」+ 子任务 acceptance_md → 建的 == 要的?用户能做到原始诉求/预期效果吗?达不成 = 不 passed(代码再干净也不封口):**实现没做到目的 → 退 /pp-execute-v2;方案本身就达不到 → 退 /pp-plan-v2**。

**代码质量 5 维(逐维找茬 · 映射到四审关)**

| 攻击维 | 攻击问题(往死里挑) | 对照源 | 落四审关 |
|---|---|---|---|
| **代码** | 违反红线 1-8?三层越级/倒置?50 行写成 100 行?手术刀越界? | 项目公约 AGENT.md | `code_review` |
| **数据源** | 双信源并存?类型转换漏到业务层?字段语义与现有冲突? | plan §0.0 / entries[].acceptance(v5) | `code_review` |
| **调用** | 调用链有断点?隐藏副作用?跨模块约束被破坏?import 上层? | plan §6 调用链 | `code_review` |
| **封装/复用** | 调用方不止一行?职责不单一?**重复造轮子**(生态/项目已有)? | plan §1 复用 | `reuse_review` |
| **逻辑流程图** | 画 mermaid「实测调用链」· 与 plan §6 设计链逐节点比对偏差;对照 §0.0 上下游影响表核验预测(预测「不受影响」实测却受影响 = 方案级错误) | plan §0.0 + §6 | `code_review` / `purpose_acceptance` |
| **真实测试** | 重跑 execute 的验收命令 + 真实链路 · 确认"全绿"不是侥幸 · 非 mock | entries[].acceptance(v5) | `test_check`(复核) |

## 二、审查流程(6 步)

```
Step 1 · workflow_get 看全子任务(execute 产出)+ next_actions/blockers
Step 2 · 先过维0 目的达成(对照 entries[].acceptance(v5))· 不达 → 退 execute/plan
Step 3 · 逐子任务 hostile 四审 → review_subtask_check 逐关 passed:
         code_review(代码/数据源/调用/逻辑流程图维)· test_check(重跑验收复核)
         purpose_acceptance(建的=要的)· reuse_review(重复造轮子/复用维)
         任一 false → 修根因 → 重审该关 + 真实测试 → passed 才继续(不口头放过)
Step 4 · 子任务四审齐 passed + 前序子任务 done → finish_subtask 封口
Step 5 · 全子任务封口 → set_final_acceptance{passed:true, report_md}(父任务统一验收)
         report_md = 5 维结论 + 实测 mermaid 流程图 + 真实测试输出 + 残留风险
Step 6 · 全绿(无 must 未解;should 可延 → 记入 report_md 残留风险)→ 末尾按公约交付 5 段
         + 附「近期回顾」→ 下一步 /pp-archive-v2
```

## 三、任务回顾(附加模块 · --recap 或审查末尾附 · 可整节删除不影响审查本体)

> 本节额外依赖 ppwiki task 模块 · 无 ppwiki 直接跳过 · 移植时随 §Store 接线一并处置。

| 任务 | 阶段进度 | 做了什么 | 没做 / 遗留 |
|---|---|---|---|
| PPAgent纯MCP核心重构 | 根因✓ 方案✓ 执行🔄 审查○ 归档○ | 工具封顶根治 · 启动器双栏 | 审查未过 · 未归档 |
| 工具对管闭环 | 根因✓ 方案✓ 执行✓ 审查✓ 归档⊘ | 全链路打通 | 漏归档(卡 archive) |

> 高亮「卡在哪个阶段」的任务(读 workflow_get.phase + progress)+ 一句话建议下一步喊哪个命令。

## 四、审查结论留存(进引擎字段 · 不写游离 md)

```
逐关结论     → review_subtask_check 的 note(code_review/purpose_acceptance/reuse_review)/ result(test_check)
封口          → finish_subtask
父任务统一验收 → set_final_acceptance.report_md:
  ├ §1 五维攻击结论(代码/数据源/封装·复用/调用/逻辑流程图 · 各维 ✓/✗ + 证据 file:line)
  ├ §2 实测调用链(mermaid)+ §0.0 上下游预测核验(逐节点 ✓/✗ · 全局图需修订处标明 · 供 archive 灌 wiki)
  ├ §3 真实测试输出(命令 + 实际结果 · 去敏)
  └ §4 残留风险(触发/影响/缓解)
```

## Store 接线(ppwiki · 移植时改写/删除本节 · 方法论正文零 ppwiki)

| 记账点 | 时机 | op |
|---|---|---|
| ⓪ | 全程 | `task --workflow_get {task_id}` → 看子任务 + guidance/blockers |
| ① | Step 3 逐子任务四审 | `task --review_subtask_check {task_id, check, passed, note/reviewer/commands/result}`(四关:code_review/test_check/purpose_acceptance/reuse_review) |
| ② | Step 4 封口 | `task --finish_subtask {task_id}`(四审全 passed + 前序 done 才允许) |
| ③ | Step 5 父任务统一验收 | `task --set_final_acceptance {task_id, passed, report_md}` |
| ④ | §三 任务回顾(可选) | `task --list` → 逐个 `task --workflow_get`(读 phase + progress 状态机) |

- op / 参数以 `wiki('system --help', {module:'task'})` 为准 · 禁凭记忆
- 顶层 `review --submit/resolve` 仅作可选「跨切面发现台账」· 收口主路 = 子任务四审 · 以 `workflow_get` 为准 · 不臆断
- phase 推进 / 下一步:照 `workflow_get.guidance.next_actions`,**不硬编码 P 编号**
- **不写 证据/审查报告.md**(结论进四审 note + final_acceptance.report_md)
- 离线降级:①②③ 改落本地报告(标「未入库」)· 闭环照走;④ 跳过 · 禁静默

## 五、用户视角对话样例

```
你: /pp-review-v2 PPAgent纯MCP核心重构

AI: [审查 + 回顾 v2] 启动 — hostile 5 维攻击 → 四审封口 · 真实测试复核

    进度 [●○○○○○]  1/6 · workflow_get:3 子任务待审 · 0 blockers
    进度 [●●○○○○]  2/6 · 维0 目的达成 ✓ 对照 entries[].acceptance(v5) · 建的=要的
    进度 [●●●○○○]  3/6 · 逐子任务四审
       [L2 业务层]
         code_review        ✗ pp_agent.py:120 业务层 try-except 吞错 → passed=false
           → 修根因:改抛具体错 · 业务层只转译 → 重审 → passed=true
         test_check(复核)   ✓ 重跑 curl 真实链路 ok(非侥幸)
         purpose_acceptance ✓ 建的=要的
         reuse_review       ✗ tool_cap 逻辑重复 2 处 → 底层统一信源 → passed=true
       → finish_subtask L2 ✓(四审齐 + 前序 done)
       [L1][L3] 四审齐 → finish ✓
    进度 [●●●●○○]  4/6 · 全子任务封口 ✓
    进度 [●●●●●○]  5/6 · set_final_acceptance{passed:true, report_md}(5维+实测图+残留)
    进度 [●●●●●●]  6/6 · 近期回顾
       工具对管闭环  卡 归档 → 建议 /pp-archive-v2
    ┌──── 审查通过 · 0 must 残留 · 全子任务封口 ────┐
    │ 下一步:/pp-archive-v2(同步资产 + 归档)       │
    └──────────────────────────────────────────────┘
```

## 六、失败 / 边界

| 情况 | 处置 |
|---|---|
| 四审某关 false | 必修根因 · 重审该关才 passed(不口头记一笔放过)· 不 finish_subtask |
| 真实测试复核挂(test_check) | 退回 /pp-execute-v2 · execute 的"全绿"是侥幸 |
| 实测链 ≠ 设计链 | 偏差入 report_md · 判实现错还是方案错 · 错在方案 → 回 /pp-plan-v2 |
| §0.0 上下游预测失准 | 方案级错误 → 回 /pp-plan-v2 修 §0.0+§0.4 · 全局图修订记入 report_md §2 |
| finish_subtask 报错(前序未 done) | 看 workflow_get.blockers · 先封前序 · 不跳序 |
| op 报错 | `wiki('system --help',{module:'task'})` 核对 |
| --recap 无近期任务 | 提示"近期无 active 任务" · 正常退出 |

## 七、不做的事

- ❌ 不夸自己(切 hostile · 默认有问题)
- ❌ 不口头略过发现(必落四审 note/result · 离线落本地标「未入库」)
- ❌ 四审某关 false 不修就 finish_subtask
- ❌ 不用 mock 冒充真实测试复核(test_check)
- ❌ 不写业务代码以外的顺手重构(手术刀)
- ❌ **不写游离 md**(结论进四审 + final_acceptance.report_md)
- ❌ 不替 /pp-archive-v2 写 wiki(report_md §2 供其取用)

## 八、契约

```
上游:/pp-execute-v2 的子任务产出(implementation/output + test_check)+ entries[].acceptance(v5)
产出:四审全 passed · 全子任务 finish_subtask · set_final_acceptance(passed,report_md)
下游:/pp-archive-v2(取 report_md §2 实测流程图灌 wiki · 资产入库 + 归档)
全链路 / 字段映射 / 所有权 → /pp-pipeline
```
