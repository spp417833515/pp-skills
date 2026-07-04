---
name: pp-pipeline
description: pp-* v2 流水线唯一信源:5 技能链路图 · 命令↔引擎阶段映射 · 富内容↔引擎字段映射 · 生命周期所有权。路线甲(引擎原生单源):富内容全进 ppwiki 结构化字段,task --workflow_get 唯一数据源,技能不写游离 md / 不碰文件系统。只读参考,不执行动作;5 个 pp-*-v2 技能不再内联链路细节,一律引用本文件。
disable-model-invocation: true
---

# /pp-pipeline — 流水线单一信源(只读参考 · 引擎原生单源)

> 改链路 / 字段映射 / 所有权,**只改本文件**;5 个技能文件只持各自的接口契约。
> 核心原则(路线甲):富内容**全进 ppwiki 引擎结构化字段** · `task --workflow_get` 是唯一数据源 · 技能**不写游离 md 任务目录、不 mkdir/mv、不碰文件系统**。物理路径由引擎按 `system --layout` 管。

## 一、唯一链路(5 技能)

```
/pp-clarify-v2 → /pp-plan-v2 → /pp-execute-v2 → /pp-review-v2 → /pp-archive-v2
    根因           方案            执行             审查            归档(同步+收尾)
```

| 命令 | 阶段 | 定位 |
|---|---|---|
| /pp-clarify-v2 | 根因 | 事实vs判断四分闸 + 决策点 A/B + 三件产物 → 全进 clarify 引擎字段 |
| /pp-plan-v2 | 方案 | 读 clarify 三件产物 · `derive_task` 派生顶层任务(唯一入口)· 方案进 task.context/plan |
| /pp-execute-v2 | 执行 | `set_subtask` 串行解锁施工 · 循环跑命令式验收到全绿 · 产出进子任务字段 |
| /pp-review-v2 | 审查 | hostile 四审(代码/测试/目的/复用)逐子任务收口 + 父任务统一验收 |
| /pp-archive-v2 | 归档 | 提复用资产入 reusable_code/wiki/decision(幂等)+ `task --archive`(引擎内部 move) |

## 二、命令 ↔ 引擎阶段映射(5 命令 ↔ 用户面 5 阶段)

```
根因 → 方案 → 执行 → 审查 → 归档
```

- **阶段标签来自用户面单源**(Hook 注入的 `根因/方案/执行/审查/归档`,= `task_carry_template`)。
- **phase 推进与 op 选择,一律照 `task --workflow_get` 返回的 `guidance.next_actions[{op,params}]` 调**(params 已预填 `to_phase` 等)。技能**禁硬编码引擎 P1–P5 码或 phase↔op 映射**——引擎内部 P 码存在双标签口径(`_task_phase` vs `task_carry_template`),硬编码必踩错;decouple 后此冲突与技能无关。
- op / 参数一律以 `wiki('system --help', {module:X})` 为准 · 禁凭记忆。

## 三、生命周期所有权(谁调哪个 op · 写哪个引擎对象)

| 引擎对象 | 创建者 | 写入者 | 消费者 |
|---|---|---|---|
| **clarify 记录** | clarify(`--create`) | clarify(`append_requirement`/`set_understanding`/`append`+`answer`+`decide_clarification`/`set_goal`/`set_notes`/`lock`) | plan(`--get` 读三件产物) |
| **顶层 task** | **plan(`clarify --derive_task`:仅 locked · 快照入 task · 物理删原澄清 · 已决策自动桥接 decision)** | plan(`fill_context`/`fill_plan`/`review_plan`/`approve_plan`)· archive(`set_final_acceptance`/`archive`) | 全程 `workflow_get` |
| **子任务(subtask)** | plan(`set_subtask` · parent=顶层 task · P3 拆分+设计八项 · 拍板双闸后列表锁禁再建) | execute(`set_subtask`:激活/implementation/output)· review(`review_subtask_check`/`finish_subtask`) | `workflow_get`(computed.unlocked) |
| **reusable_code / wiki / decision 条目** | archive(查重→`create`) | archive(`update`,幂等) | 后续任务 |

**标识传递**:clarify `name`(澄清名)→ `derive_task` 返回 `task_id` → 此后全用 `task_id`(`workflow_get`/`set_subtask` 的 parent 等)。子任务 id 形如 `父/子名`。

## 四、富内容 ↔ 引擎字段映射(路线甲单源 · 取代旧「游离 md 目录」)

> 旧版自己 `mkdir .pp/wiki/当前任务/[名]/` 写 3 份 md + 证据/,是因为老引擎 task 无字段可装。**task v05 已长出字段,富内容一律进字段**;读取走 `workflow_get`(UI/AI 同源)。

| 旧游离产物 | 现引擎字段(单源) |
|---|---|
| 三件产物(原始诉求/澄清后描述/预期效果) | `clarify --set_requirement_goal`(各条目 goal+acceptance(v5 entries 逐条)) |
| 决策点 A/B | `clarify` append/answer/`decide_clarification`(→ derive 时自动入 decision) |
| 证据(代码证据/外部证据) | `clarify --set_understanding`(text 带 file:line + confidence)+ `set_notes`(外部 URL) |
| 对话和澄清.md | `task --fill_context`(summary + perceived_benefit) |
| 执行方案.md(§0.0 定位/架构/五类清单) | `task --fill_plan`(approach 富 markdown + layers_needed + layer_breakdown) |
| 验收标准.md | `clarify` success_criteria + 各子任务 `acceptance_md` + 父任务 `set_final_acceptance` |
| 子任务施工/证据/执行验收 | `set_subtask`(implementation/output)+ `review_subtask_check`(test_check 的 commands/result) |
| 审查报告.md | 四审 `review_subtask_check`(note/reviewer/result)+ `set_final_acceptance`(report_md) |
| 任务总结.md + 物理 mv | `set_final_acceptance.report_md` + `task --archive`(引擎内部 current→archive move) |

- **路径**:技能不拼路径;需要结构时调 `wiki('system --layout')`(`scopes[{key,segment,display,kind,abspath}]`,上层禁硬编码)。
- **读取**:任意阶段要看任务全貌 → `task --workflow_get {task_id}`(父流程 + 全子任务 + computed.unlocked + progress + guidance)。

## 五、移植约定(对齐公约「模块化与移植测试」)

```
每技能三段式:
  ① 接口契约    输入 / 输出 / 缺依赖行为      ─┐
  ② 方法论正文  可移植 · 零 ppwiki             ├─ 移植 = ①② 原样搬走
  ③ Store 接线  ppwiki op 归拢一节            ─┘  + 改写/删除 ③
```

- ②方法论正文(怎么澄清 / 定方案 / 四审)不出现 ppwiki 调用 · 纯方法,可整段搬到任何环境。
- ③Store 接线 = 路线甲下「富内容写哪个引擎字段」的归拢。移植到非 ppwiki 环境时:把 ③ 改写为本地存储(如写 md 文件)即可,①② 不动。
- 离线降级(无 ppwiki):③ 整节失效 → 经用户确认,富内容暂落本地 md 并显式标「未入库」,恢复后重跑补录;**禁静默跳过**。
