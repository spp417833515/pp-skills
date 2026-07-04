---
name: pp-plan-v2
description: 基于上下文的最终方案制定(方案阶段)。读 clarify 锁定的逐条产物(entries 每条 goal/acceptance/layer) → clarify --derive_task 派生顶层任务(唯一入口·原澄清物理删)→ 方案进 task.context/plan 引擎字段(approach 含 §0.0 逻辑流程图定位/架构图/五类产出/影响面)· 内部 12 项自审 + 子代理对抗 → review_plan 双关 → 用户 approve_plan 拍板进执行。开发中项目铁律:有问题就清理+重建,禁缝缝补补。
disable-model-invocation: true
---

# /pp-plan-v2 — 最终方案制定(派生唯一入口 + 方案进引擎字段)

## 定位

```
不是从零问需求 · 是把 clarify 逐条产物(entries 每条 goal/acceptance/layer)沉淀为可执行的最终方案,写进 task 引擎字段
不是只产新代码方案 · 也能产 "优化 / 清理 / 审查方案" 类产出
不是缝缝补补保留兼容 · 有问题代码直接清理+重建
顶层任务唯一入口 = clarify --derive_task(公开 task --create(parent=None) 被引擎守卫拒绝)
```

## 调用方式

```
/pp-plan-v2              读 clarify 最新 locked 的逐条产物(entries 每条 goal/acceptance/layer) · 自动提炼任务名
/pp-plan-v2 <澄清名>     显式指定 clarify 记录
```

无 clarify lock 的逐条产物(entries 每条 goal/acceptance/layer) → 提示先 /pp-clarify-v2 · 不强进(三段闸门 ①→②)。

## 接口契约(移植先看这 · 三段式见 /pp-pipeline §五)

| 项 | 内容 |
|---|---|
| 输入 | `clarify --get` 逐条产物(entries 每条 goal/acceptance/layer)(entries(v5 英文键)逐条(目的+验收标准) + 各条目的 协商/AI理解) |
| 输出 | 顶层 task(`derive_task`)+ `task.context`(理解)+ `task.plan`(方案富文档 + 分层)+ **全部子任务(设计八项齐)** · `review_plan` 双关通过 · `approve_plan` 拍板 |
| Store 接线 | ppwiki clarify/task 模块 · 方案进字段 → 见 §Store 接线 |
| 缺依赖行为 | 无逐条产物(entries 每条 goal/acceptance/layer) → 不强进;无 ppwiki → 读本地澄清.md · 方案暂落本地并声明「task 未派生」 |

## 开发中项目铁律(贯穿全程)

```
代码 / 逻辑 / 数据有问题  →  直接清理干净 + 构建正确的
禁止: 缝缝补补 / 兼容旧版 / 保留错误链路 / try-except 吞错
理由: 缝补 = 潜在错误 = 长期翻倍还债
```

任何违反 → 方案作废 · 重做。

## 输出强制要求(全进引擎字段 · 不写游离 md)

方案落 **3 块引擎字段 · 缺一不可**:

```
task.context  ← fill_context   对话理解(summary)+ 用户感知效果(perceived_benefit)
task.plan     ← fill_plan      approach(富 markdown:§0.0-§0.4 + 五类清单论证)
                               + layers_needed(⊆{逻辑层,业务层,用户层}·底→上)
                               + layer_breakdown{层:{acceptance,test_strategy,files}}
验收口径      ← clarify acceptance(条目级·v5)(已锁)+ 各子任务 acceptance_md(**本阶段拆分时填** · 拍板双闸后 execute 不可再建)
```

**自审报告不落字段**(内部门槛 · 结论进 `review_plan` 双关)。

## 一、方案要素契约(进 fill_context / fill_plan)

### context(理解 · 进 fill_context)

| 要素 | 必含 | 落点 |
|---|---|---|
| AI 对话理解 | 每段原话 · AI 的解读 · 无臆测 | summary |
| 已锁/未决决策 | 候选→选定→理由(来自 clarify clarifications) | summary |
| 用户感知效果 | 完成后用户能看到/不再被困扰什么 | perceived_benefit |

### plan.approach(富 markdown · 进 fill_plan 的 approach)

| 章节 | 必含 |
|---|---|
| §0 | 顶部铁律("开发中项目禁缝缝补补" · 复述给执行者) |
| §0.0 | **逻辑流程图定位**(三件套:① 全局逻辑流程图 mermaid · 节点=抽象逻辑动词非文件名;② 任务节点标记:改节点内部 还是 节点间契约;③ 上下游影响表:关联节点/方向/契约变?/影响/处置) |
| §0.1 | **架构改前/改后**(ASCII 图)+ 架构3问(能承载?最简路径?能长期用?)· 任一否→先改架构 |
| §0.2 | **底层探测表**(动词→底层能力 ❌缺/✅有)· 缺→子任务首项"补底层 X" |
| §0.4 | **影响范围清单**(由 §0.0 上下游影响表推导 · 每条标来源节点/边 · 确认不误伤) |
| §1-§5 | **五类产出清单**(复用 file:line / 优化 file:line / 修改 file:line / 清理 file:line / 新建预定路径+签名) |
| §6 | 调用链图(mermaid · 串起 §1-§5) |
| §8 | 风险与取舍(触发 / 影响 / 缓解 / 决策) |

### plan.layers_needed + layer_breakdown(进 fill_plan)

- `layers_needed` = 本任务涉及的层 ⊆ {逻辑层,业务层,用户层}·**严格底→上**(对应 §0.3 分层 + §7 执行顺序)。
- `layer_breakdown` = `{层名:{acceptance:[...], test_strategy, files:[...]}}`(五类清单按层归位 + 各层验收/测试策略;§9 完成定义含真实链路硬条件)。

## 二、产出类型可灵活配比

```
新功能任务      → §1+§3+§5 主力(复用 + 修改 + 新建)
重构任务        → §2+§4 主力(优化 + 清理)
审查/优化方案   → 不一定出 §5(可全无新代码 · 只给优化建议)
Bug 根治        → §3+§4 主力(修根因 + 清理绕行)

§ 全空不允许 · 至少有一类产出
```

## 三、内部自审 12 项(门槛 · 结论进 review_plan)

切到"审查者"角色 · 第一性原理过 12 项:

| # | 自审项 | 通过标志 |
|---|---|---|
| 1 | 对话理解一致 | context.summary ↔ clarify 逐条产物(entries 每条 goal/acceptance/layer)对得上 · 无臆测 |
| 2 | 决策点齐全 | clarify 所有 decided 决策都落 context |
| 3 | 攻击性 4 维都查过 | 代码风格 / 数据 / 逻辑 / 重复造轮子 各查 |
| 4 | **产出优先级** | 复用 > 优化 > 修改 > 清理 > 新建 · 跳级必证不可 |
| 5 | 改动都带证据 | §1-§4 file:line · §5 预定路径 + 签名 |
| 6 | 真实链路 ≠ 纯 mock | layer_breakdown 含 ≥ 1 条真实 URL/KEY |
| 7 | **禁缝缝补补** | 有问题代码必入 §4 清理 · 非 fallback / 兼容 / 双链路 |
| 8 | **架构合理** | §0.1 改前/改后图 + 架构3问 全过 |
| 9 | **分层无污染** | layers_needed 底→上 · 无 UI↔Store 直连 / UI→逻辑层 做业务直跳 |
| 10 | **底层探测齐** | §0.2 动词→底层 ❌缺/✅有 表在 · 缺→子任务首项"补底层 X" |
| 11 | **影响范围齐** | §0.4 清单在 · 每条可溯源到 §0.0 节点/边 |
| 12 | **逻辑定位齐** | §0.0 三件套在 · 每个相邻节点有契约判定 |

任一项不通过 → 内部回写 approach/context → 再自审 · 循环 ≤ 3 轮。3 轮仍有缺口 → 暂停 · 列缺口给用户 · **不强出方案**。

**12 项过后 · 子代理模拟验证(对抗自审升级 · 用 Agent 工具派子代理)**:
```
派 subagent 扮 hostile executor · 拿 plan.approach 模拟跑一遍 · 专挑漏洞:
  · §1 复用的 file:line 真存在?函数签名对得上?(不存在 = 跳级新建伪装)
  · §0.0 全局流程图是真的吗?节点/边有代码证据吗?漏画上下游?
  · layer_breakdown 验收命令真能跑?期望值现实?真实链路 URL/KEY 可达?
  · §7 执行顺序会不会依赖倒置卡死?
  · 藏着缝缝补补 / 双信源 / try-except 吞错 / fallback?
子代理产「攻击报告」→ 命中缺口回写 → 再过 12 自审 · 循环 ≤ 2 轮。
```
全部通过 + 子代理无致命攻击 → 写 fill_context + fill_plan,再 review_plan 双关。

## 四、违规项(红线 · 命中即作废)

| # | 违规 | 判定 |
|---|---|---|
| 1 | 缝缝补补 | 现存错误代码未入 §4 清理 · 改用 fallback / 兼容 / 双链路 |
| 2 | 结论不带 file:line | §1-§4 任一条没源码定位 = 猜测 |
| 3 | 重复造轮子 | §5 新建但未证明无可复用 |
| 4 | 验收含糊 | "应该 / 大概 / 通常" / 无可执行命令 + 期望值 |
| 5 | 跳级新建 | 跳过 §1 复用 / §2 优化 / §3 修改 直接 §5 新建无理由 |
| 6 | 派生绕行 | 用 task --create 建顶层 · 不走 clarify --derive_task |
| 7 | 自审未过即写字段 | 12 项门槛未过即 fill_plan / approve_plan |
| 8 | 决策臆测 | context 决策不来自 clarify · 是 AI 猜的 |

## Store 接线(ppwiki · 移植时改写/删除本节 · 方法论正文零 ppwiki)

| 记账点 | 时机 | op(方案进字段) |
|---|---|---|
| ① | 启动 · 读逐条产物(entries 每条 goal/acceptance/layer) | `clarify --get {name}`(name=null 取最新 active locked) |
| ② | 方法论想透后 · 派生 | `clarify --derive_task {name, priority}`(**唯一入口** · 快照入 task · **物理删原澄清** · 已决策自动桥接 decision · 返回 task_id) |
| ③ | 写理解 | `task --fill_context {task_id, summary, perceived_benefit, related_wiki, related_files, reusable}` |
| ④ | 写方案 | `task --fill_plan {task_id, approach, layers_needed, layer_breakdown}` |
| ⑤ | 自审收口 | `task --review_plan {task_id, benefit_check_passed, code_style_check_passed, reviewer_notes}` |
| ⑤.5 | **拆子任务 + 设计八项**(拍板前必做) | `task --set_subtask {parent, name, layer, order, requirement_md, root_cause_md, purpose_md, reuse, logic_flow, scope, acceptance_md}`(按 layer_breakdown 五类清单 · order 底→上串行;**设计八项必填**=任务描述(requirement_md)/根因(root_cause_md)/预期目的(purpose_md)/复用决策(reuse.decision)/当前逻辑流程图(logic_flow.before)/目的逻辑流程图(logic_flow.after)/数据源(scope)/验收标准(acceptance_md)——中文名=引擎报错用名) |
| ⑥ | 用户拍板 | `task --approve_plan {task_id}`(双关须 true · **拍板双闸**:无子任务不可拍板 + 全部子任务设计八项批量校,缺失报「设计必备字段缺失(拍板批量校): {子任务id: [字段...]}」· 通过后推进 · init layers · 进执行;**拍板后列表锁定禁再建子任务**) |

- op / 参数以 `wiki('system --help', {module:'clarify'/'task'})` 为准 · 禁凭记忆
- phase 推进交 `task --workflow_get` 的 `guidance.next_actions`,**不硬编码 P 编号**(→ /pp-pipeline §二)
- **不写 3 份游离 md**(富内容进 context/plan 字段)
- 离线降级:① 改读本地澄清.md;②-⑥ 跳过并显式声明「task 未派生 / 方案落本地」· 禁静默

## 五、用户视角对话模板

```
AI: /pp-plan-v2 启动 — 读 clarify 逐条产物(entries 每条 goal/acceptance/layer) · 方案进 task 引擎字段

    进度 [●○○○○○○]  1/7 · clarify --get 读逐条产物(entries 每条 goal/acceptance/layer)
    进度 [●●○○○○○]  2/7 · 内部想透方案(对话理解 / 攻击性验收 4 维)
    进度 [●●●○○○○]  3/7 · 五类清单 + §0.0-§0.4(逻辑定位/架构/底层探测/影响面)
       ✓ 复用 X · 优化 Y · 修改 Z · 清理 W · 新建 V
    进度 [●●●●○○○]  4/7 · 内部自审 12 项 + 子代理对抗(不输出过程)
       [循环若有缺口: 回写 → 再自审]
    进度 [●●●●●○○○]  5/8 · derive_task 派生顶层任务(原澄清物理删)→ task_id=X
    进度 [●●●●●●○○]  6/8 · fill_context + fill_plan + review_plan 双关
       ✓ benefit_check ✓ code_style_check
    进度 [●●●●●●●○]  7/8 · 拆子任务 + 设计八项(⑤.5 · 拍板双闸的前提)
       ✓ 每个子任务:描述/根因/目的/复用/双流程图/数据源/验收 全填
    进度 [●●●●●●●●]  8/8 · 等你拍板
    ┌──── 方案已进 task 引擎字段 ────┐
    │ 看全貌:task --workflow_get {X}  │
    └─────────────────────────────────┘
      A. 拍板 approve_plan(推荐 · 进执行 init layers · /pp-execute-v2)
      B. 改某要素(说明改哪 → 回写 context/plan)
      C. 整体重做
      D. 放弃
```

## 六、契约

```
上游:clarify 逐条产物(entries 每条 goal/acceptance/layer)(entries(v5 英文键)逐条(目的+验收标准) + 决策/证据字段)
产出:顶层 task + context/plan 字段 · review_plan 双关过 · approve_plan 拍板(进执行)
下游:/pp-execute-v2(按已拆子任务施工 · 跑验收)
全链路 / 字段映射 / 所有权 → /pp-pipeline
```

> 划界:plan 写「验收口径」(acceptance(条目级·v5) + layer_breakdown.acceptance),/pp-review-v2 读此口径做「实测四审」· 单一信源 · 不各写一套。
