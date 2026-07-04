---
name: pp-execute-v2
description: 执行 v2(子任务串行解锁施工 · 循环跑命令式验收 → 全绿才过)。读 task.plan(workflow_get)· 按已批子任务串行施工(plan 阶段已拆·设计八项已齐·拍板后列表锁禁再建)· 逐个 unlocked 子任务激活+施工(复用>优化>修改>清理>新建)· 循环跑命令式验收比对期望值 · 红就修根因不绕行 · ≥1 真实链路非 mock · 产出进子任务 implementation/output · 自测进 review_subtask_check(test_check)。
disable-model-invocation: true
---

# /pp-execute-v2 — 执行(子任务串行解锁 + 循环验收到全绿)

## 定位

```
不是"写完就算" · 是"按已拆子任务(plan 阶段拆好)逐条跑验收命令 · 红就回修 · 全绿才过"
不是 mock 自欺 · 是真实运行(有外部依赖→≥1 真实 URL/KEY;纯内部任务→真实端到端跑)
不是黑箱 · 是每条验收命令的实际输出进子任务字段(test_check)
执行全程吃 项目公约 AGENT.md 铁律:修根因 / 禁缝补 / 手术刀 / 底层先足量
产出进引擎字段(子任务 implementation/output)· 不写游离 md
```

## 调用方式

```
/pp-execute-v2 <任务名/task_id>
先 task --workflow_get 看 plan + guidance.next_actions/blockers
```

approve_plan 未拍板 / 无 plan → 阻断 · 提示先 /pp-plan-v2 拍板。

## 接口契约(移植先看这 · 三段式见 /pp-pipeline §五)

| 项 | 内容 |
|---|---|
| 输入 | `task --workflow_get`:task.plan(approach_md + layers_needed + layer_breakdown)+ success_criteria |
| 输出 | 子任务(`set_subtask`)施工全绿 + `implementation`/`output` 字段 + 自测 `test_check` |
| Store 接线 | ppwiki task v05 子任务 · workflow_get 驱动 → 见 §Store 接线 |
| 缺依赖行为 | 无 plan/未 approve → 阻断回 /pp-plan-v2;无 ppwiki → 跳过记账(声明)· 施工与验收循环照跑 |

## 一、执行铁律(继承 项目公约 AGENT.md · 命中即停回退)

| 铁律 | 触发即停 | 动作 |
|---|---|---|
| 修根因不绕行(红线1) | 报错想加 try-except 吞 + fallback | 查调用栈 → 定位根因 → 修逻辑 |
| 从根源(红线3) | 修了上游根因但下游还留 if"兼容"/绕行码 | 修上游 + **删下游所有绕行码** |
| 禁缝缝补补(红线8) | 想加 wrap/hack/兼容旧版/双信源 | 停 → 回补底层 → 业务层一行 |
| 手术刀(红线6) | 顺手改邻接/格式/没坏的 | 只动 plan layer_breakdown 列出的目标 |
| 分层不越级(红线7) | UI 直读 Store / UI 调逻辑层做业务 | 经业务层中转 |
| 执行顺序 | 跳着做 | 严按 layers_needed 底→上 · 子任务 order 串行 · 复用优先 |

## 二、5 步流程

```
Step 1 · workflow_get 看 plan + next_actions/blockers(approve_plan 后引擎已进执行 · init layers)

Step 2 · 激活当前子任务(子任务已在 plan 阶段拆好 · 拍板后列表锁禁再建)
         · workflow_get.guidance 给「开始「X」」→ set_subtask {task_id, status:'active'}
         · 被拦「设计必备字段缺失: [XX]·请在同一次 set_subtask 调用中补齐并置 status=active」
           → 按 hint **在同一次调用中**补齐缺失字段 + status:'active'(执行态写闸门下
             先填后激活不可行 · 单次合并调用是唯一合法路径;guidance hint 同源给缺失清单)
         · 五类优先级(施工顺序内化):复用 §1 > 优化 §2 > 修改 §3 > 清理 §4 > 新建 §5
         · 清理 §4 = 直接删错误/冗余代码(不留 deprecated 二路)

Step 3 · 逐个 unlocked 子任务施工(workflow_get.subtasks[].computed.unlocked 给当前可做的)
         · 施工要点/改动文件 → set_subtask 的 implementation(approach_md/steps_md/changed_files)
         · 循环验收(核心 · 直到全绿):
             for 每条该子任务 acceptance 命令:
                 跑 Bash 命令 → 抓「实际输出」→ 比对「精确期望值」
                 ┌ 绿 → 记 ✓ · 下一条
                 └ 红 → 定位根因 → 修 → 重跑(禁吞错 / 禁改期望值凑绿)· 同一条 3 次仍红 → 暂停列用户
         · §6 真实运行:有外部依赖 → ≥1 真实 URL/KEY 跑通;纯内部 → 真实端到端跑 · 均非 mock
         · 验收命令+实际输出 → review_subtask_check{check:'test_check', commands, result, passed:true}

Step 4 · 提交前自检(公约自检清单 11 项)· 重点 7分层 / 8无污染 / 9业务层一行 / 10底层足量
         任一不过→回修(非记一笔放过)(自查 during 施工;review 阶段再做 hostile 外审)

Step 5 · 子任务全绿收口 → set_subtask 的 output(summary_md/changed_files/created_assets)
         下一步:进 /pp-review-v2(四审 + finish_subtask 封口)
```

## 三、产出留存(进子任务引擎字段 · 不写游离 md)

```
施工要点/改动     → set_subtask: implementation{approach_md, steps_md, changed_files}
验收命令+实际输出 → review_subtask_check{check:'test_check', commands:[...], result:'...', passed}
收口总结/产物     → set_subtask: output{summary_md, changed_files, created_assets}
```

| 子任务 | 验收命令 | 期望值 | 实际输出 | test_check |
|---|---|---|---|---|
| L1 逻辑层 | `pytest -q libs/x` | `42 passed` | `42 passed` | ✓ |
| L2 业务层 | `curl -s $REAL_URL` | `200 {ok:true}` | `200 {ok:true}` | ✓ |

> 真实链路输出原文(去敏后)进 test_check 的 result · 作为"非 mock"的物证。

## Store 接线(ppwiki · 移植时改写/删除本节 · 方法论正文零 ppwiki)

| 记账点 | 时机 | op |
|---|---|---|
| ⓪ | 全程 | `task --workflow_get {task_id}` → 照 guidance.next_actions/blockers · subtasks[].computed.unlocked 给当前子任务 |
| ① | Step 2 激活子任务 | `task --set_subtask {task_id, status:'active'}`(被拦=同一次调用补齐设计八项+激活;子任务建在 plan 阶段 · 此处禁 parent/name 建新) |
| ② | Step 3 施工记录 | `task --set_subtask {task_id, implementation}` |
| ③ | Step 3 自测验收 | `task --review_subtask_check {task_id, check:'test_check', passed, commands, result}` |
| ④ | Step 5 收口 | `task --set_subtask {task_id, output}` |

- op / 参数以 `wiki('system --help', {module:'task'})` 为准 · 禁凭记忆
- task 由 /pp-plan-v2 `derive_task` 诞生(所有权 → /pp-pipeline §三);task 不存在/未 approve → 回 plan · 不在本技能补建顶层
- phase 推进 / 下一步:照 `workflow_get.guidance.next_actions`,**不硬编码 P 编号**
- **不写 证据/执行验收.md**(产出进子任务字段)
- 四审里 code_review/purpose_acceptance/reuse_review 留给 /pp-review-v2;execute 只记 test_check(自测)
- 离线降级:跳过记账并显式声明 · 验收循环照跑 · 禁静默

## 四、用户视角对话样例

```
你: /pp-execute-v2 PPAgent纯MCP核心重构

AI: [执行 v2] 启动 — workflow_get 读 plan · 激活已拆子任务 · 循环验收到全绿

    进度 [●○○○○]  1/5 · workflow_get:phase=执行 · plan 3 层 · 0 blockers
    进度 [●●○○○]  2/5 · 激活当前子任务(plan 已拆 · guidance 给开始动作)
       ✓ L1 逻辑层(order 10)· L2 业务层(order 20)· L3 用户层(order 30)
    进度 [●●●○○]  3/5 · 逐子任务施工 + 循环验收
       [L1] 复用 3 · 修改 2 · 清理 1(删旧 catalog)
            pytest -q libs/x     期望 42 passed   实际 42 passed   test_check ✓
       [L2] 工具发现数            期望 ≥3          实际 0           ✗
            → 根因:注入点漏传 mcp_runtime(非加 fallback)→ 修 · 重跑 → 4 ✓
            curl 真实链路 health  期望 ok          实际 ok          test_check ✓
       [L3] ... ✓
    进度 [●●●●○]  4/5 · 提交前自检 11 项 ✓
    进度 [●●●●●]  5/5 · 各子任务 output 收口 ✓
    ┌──── 执行完成 · 全绿(test_check 已记)────┐
    │ 下一步:/pp-review-v2(四审 + 封口)         │
    └────────────────────────────────────────────┘
```

## 五、失败 / 边界

| 情况 | 处置 |
|---|---|
| 验收命令始终红 | 不改期望值凑绿 · 定位根因 · 3 次仍红 → 暂停列给用户 |
| 外部依赖型任务无 KEY/URL | 阻断让用户提供;纯内部任务 → 真实端到端跑替代(仍非 mock) |
| 想加 fallback 绕过 | 红线8 命中 · 停 · 回补底层 |
| plan 缺某层能力 | 翻案:回 /pp-plan-v2 补底层项 · 不在业务层 hack |
| 子任务被 blockers 卡 | 看 workflow_get.blockers 的 reason_md · 先解前序 · 不跳序 |
| task op 报错 | 阻断 · `wiki('system --help',{module:'task'})` 核对 op/参数 |

## 六、不做的事

- ❌ 不改期望值凑绿(改的是代码不是验收)
- ❌ 不加 try-except 吞错 + fallback 兜底
- ❌ 不缝缝补补 / 不留 deprecated 二路
- ❌ 不跳执行顺序(底→上 · 子任务 order 串行)
- ❌ 不用纯 mock 冒充真实链路
- ❌ **不写游离 md**(产出进子任务字段)
- ❌ 不顺手改 plan 之外的代码(手术刀)
- ❌ 不替 review 做四审封口(只记 test_check 自测)

## 七、契约

```
上游:/pp-plan-v2 的 task.plan(approve_plan 拍板)+ success_criteria
产出:子任务全绿(implementation/output + test_check)
下游:/pp-review-v2(hostile 四审 · finish_subtask 封口 · 重跑关键验收)
全链路 / 字段映射 / 所有权 → /pp-pipeline
```
