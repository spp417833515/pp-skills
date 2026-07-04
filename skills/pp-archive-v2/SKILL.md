---
name: pp-archive-v2
description: 任务收尾 v2(同步 + 归档 2 合 1 · 吸收原 pp-sync)。审查通过后:① 提复用资产入 ppwiki — 复用代码走 reusable_code 模块、文档/组件/数据说明走 wiki 模块、决策走 decision 模块(幂等:查重→update/create · 写后回读);② task --archive 收尾(引擎内部完成 current→archive 物理 move · 技能不 mv)。任务总结进 set_final_acceptance.report_md,不写游离 md。
disable-model-invocation: true
---

# /pp-archive-v2 — 任务收尾(同步资产 + 归档)

## 定位

```
任务收尾两件事(审查已通过):
  · 同步    把本次产出沉淀成「可复用知识」:
            复用代码 → reusable_code 模块 · 文档/组件/数据说明 → wiki 模块 · 决策 → decision 模块
            幂等(查重 → update / create)· 写后回读 · 可独立反复跑
  · 归档    task --archive — 引擎内部完成 当前任务→任务归档 的物理 move(技能不 mkdir/mv/碰文件系统)

⚠ 同步已从独立 /pp-sync 吸收回本命令(单一收尾入口)。
```

## 调用方式

```
/pp-archive-v2 <任务名/task_id>
先 task --workflow_get 确认 final_acceptance.passed + 全子任务 done
```

验收通过 = review 已写 `set_final_acceptance{passed:true}`(信任 · 不重新验收)。

## 接口契约(移植先看这 · 三段式见 /pp-pipeline §五)

| 项 | 内容 |
|---|---|
| 输入 | `task --workflow_get`:plan 五类清单 + 子任务 output + final_acceptance.report_md(0 must · passed) |
| 输出 | reusable_code/wiki/decision 条目(幂等)+ `task --archive`(引擎内部 move) |
| Store 接线 | ppwiki reusable_code/wiki/decision + task 模块 → 见 §Store 接线 |
| 缺依赖行为 | 无 ppwiki → 阻断(入库即本职 · 无降级意义);上游离线期标「未入库」的产物,恢复后重跑本技能补录 |

## 一、前置校验(任一失败即阻断)

| 检查 | 通过标志(读 workflow_get) |
|---|---|
| ppwiki 连接 | `system --health` 成功 |
| 已审查通过 | `final_acceptance.passed == true` 且全子任务 `status==done`(未通过 → 提示先 /pp-review-v2) |

## 二、5 步流程

```
Step 1 · workflow_get 前置校验(final_acceptance.passed + 全子任务 done)
Step 2 · 资产提取(读 plan 五类清单 + 子任务 output + report_md → LLM 归纳可复用单元)
Step 3 · 分类路由 + 落库(幂等:查重 → update / create · 见 §三§四)
Step 4 · 写后回读校验(reusable_code --get / wiki --search · 未命中重试1次仍失败→报错阻断)
Step 5 · 收尾:总结补进 final_acceptance.report_md(收益对比/继承经验)→ 归档真链:fill_section 写 wiki_sync(synced≥1)→ advance_phase P5 → task --archive(零 force·引擎内部 move)
```

## 三、资产提取 → 落位(Step 2-3)

| 来源 | 资产类型 | 落 ppwiki 模块 |
|---|---|---|
| plan §5 新建清单 | 函数/类/模块/hook/service/adapter | **`reusable_code`**(主入口) |
| plan §1 复用清单 | 已有 · 不重复入(信任已存在) | — |
| plan §3 修改 / 业务 feature | 前端/后端业务装配 | `wiki`(前端/后端 scope) |
| plan §4 清理清单 | 反向 · 删除的 wiki 条目 | `wiki --delete` |
| UI 组件 / 数据格式 / 复用说明 | 无专门 op | `wiki`(复用 scope 文档承载) |
| review report_md §2 实测 mermaid | 逻辑流程图 | 灌 wiki 条目「逻辑流程图」字段 |
| 代码证据 + 调用维发现 | 关联代码 | 灌 wiki 条目「关联代码」字段 / reusable_code 关联代码 |
| 外部 URL/文档 | 参考类 | `wiki`(参考 scope) |
| clarify 决策 + 新增架构决策 | 决策 | `decision`(derive 已桥接已决策澄清 · 这里补增量) |

## 四、落库 + 幂等(Step 3-4 · op 以 system --help 为准)

> 条目内容按公约沟通写:简介/详细说明 = 大白话 · 结论先行 · 落 md 用 md 表 · 新手能直接复用(不堆术语)。

```
# 复用代码能力 → reusable_code 模块(中文键)
for cap in 复用能力列表:
    if reusable_code --get/--list 命中同名:
        reusable_code --update {名称, kind, 标签, 介绍, 关联代码}
    else:
        reusable_code --create {名称, kind, 标签, 介绍, 关联代码}

# 文档/组件/数据说明/业务 feature → wiki 模块(docs 域:前端|后端|复用|参考)
for doc in 文档资产列表:
    r = wiki --search {query: 关键词, scope: 前端|后端|复用|参考}
    if 命中: wiki --update {id, mode:'patch', 简介, 详细说明, 关联代码, 逻辑流程图:<取 report_md §2>}
    else:    wiki --create {id:'<scope>/<领域>/<name>', 简介, 标签, 逻辑流程图, 关联代码, 详细说明}

# 决策 → decision 模块(查重)
for d in 决策列表:
    decision --list/--get 查重 → 命中则跳过/update · 无则 decision --create {description, user_answer, decision, tags}

# 写后回读(读事实不读记忆 · 不假设成功)
for 每条刚 create/update:
    reusable_code --get / wiki --get / wiki --search → 确认落库
    未命中 → 重试 1 次 · 仍失败 → 报错阻断(不静默)
```

> `ui_components` / `data_formats` 这两个 assets scope **无专门 op** → 以 `wiki`(复用 scope)文档承载。

## Store 接线(ppwiki · 移植时改写/删除本节 · 方法论正文零 ppwiki)

| 记账点 | 时机 | op |
|---|---|---|
| ⓪ | 前置校验 | `task --workflow_get {task_id}`(final_acceptance.passed + 子任务 done) |
| ① | Step 3 复用代码 | `reusable_code --create/--update {名称, kind, 标签, 介绍, 关联代码}` |
| ② | Step 3 文档/组件/数据 | `wiki --search` 查重 → `wiki --create/--update`(docs 域 前端/后端/复用/参考) |
| ③ | Step 3 决策 | `decision --list/--get` 查重 → `decision --create {description, decision, tags}` |
| ④ | Step 5 收尾 | 总结补 `task --set_final_acceptance {task_id, passed, report_md}` → `task --fill_section {section:'wiki_sync', payload:{synced:[...]}}` → `task --advance_phase {to_phase:'P5'}` → `task --archive {task_id}`(零 force) |

- op / 参数以 `wiki('system --help', {module:'reusable_code'/'wiki'/'decision'/'task'})` 为准 · 禁凭记忆
- phase 推进 / 归档时机:照 `workflow_get.guidance.next_actions`(真链:全子任务 done+验收 passed → 写 wiki_sync → advance P5 → archive)· force=true 仅为历史数据修复逃生口,常规流程禁用
- **task --archive 引擎内部完成 current→archive 的物理 move**(冲突自动 `-rescue-NNN`)· 技能**不 mkdir/mv/碰文件系统**
- **不写 任务总结.md**(总结进 final_acceptance.report_md)
- 离线降级:阻断(入库即本职);无法降级写本地

## 五、用户视角对话样例

```
你: /pp-archive-v2 PPAgent纯MCP核心重构

AI: [收尾 v2] 启动 — 同步资产入库 + 归档

    进度 [●○○○○]  1/5 · 前置校验 ✓(final_acceptance.passed · 3 子任务 done)
    进度 [●●○○○]  2/5 · 资产提取(plan 五类清单 + 子任务 output + report_md)
       ✓ 复用能力:cap_tool_output(function)
       ✓ 决策:    工具输出 64KB 字节封顶根治 502
       ✓ 流程图:  取 report_md §2 实测 mermaid
    进度 [●●●○○]  3/5 · 分类路由 + 落库(幂等)
       [1] reusable_code cap_tool_output   无重复 → create ✓
       [2] decision 64KB 封顶              → create ✓
       [3] wiki 后端/PPAgent/纯MCP核心     命中 → update(灌逻辑流程图)✓
    进度 [●●●●○]  4/5 · 写后回读 ✓ 三条均落库
    进度 [●●●●●]  5/5 · 收尾
       ✓ 总结补进 final_acceptance.report_md(收益对比 + 继承经验)
       ✓ task --archive → 引擎内部 move 到 任务归档(已验证)
    ┌──── 任务闭环归档 ────┐
    │ 结论:闭环 · 验证:archive 落地✓ · 未处理:无 · 风险:无 · 下一步:开新任务 │
    └──────────────────────┘
    🎉 任务收尾完成。
```

## 六、失败 / 边界

| 情况 | 处置 |
|---|---|
| 未审查通过(final_acceptance 非 passed) | 阻断 · 提示先 /pp-review-v2 |
| ppwiki MCP 未连接 | 提示 `install_mcp.sh` · 阻断 |
| wiki --create 路径冲突 | 自动改 update(合并) |
| wiki/reusable_code --update 不存在 | 自动改 create |
| 决策重复 | 查重命中 → 跳过/update(保幂等) |
| archive 报错(phase 未到归档) | 照 workflow_get.next_actions 先 advance_phase · 或 `task --archive {force:true}` |
| op/参数不确定 | `wiki('system --help',{module:X})` 核对 |

## 七、不做的事

- ❌ 不写业务代码
- ❌ 不重新验收(review 已 set_final_acceptance · 信任)
- ❌ 不无脑 create(查重 → update)
- ❌ 不破坏历史 wiki 条目 / 不把决策塞 wiki(走 decision 模块)
- ❌ 不重画流程图(取 report_md §2 实测图)
- ❌ **不 mkdir/mv/碰文件系统**(archive 物理 move 由引擎内部完成)
- ❌ **不写游离 md**(总结进 final_acceptance.report_md)

## 八、契约

```
上游:/pp-review-v2 的 set_final_acceptance(passed · report_md)+ 全子任务 done
产出:reusable_code/wiki/decision 条目(幂等)+ task --archive(引擎内部 move · 任务闭环)
下游:无(链路终点)
全链路 / 字段映射 / 所有权 → /pp-pipeline
```
