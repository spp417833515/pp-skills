---
name: pp-pipeline
description: pp-* v2 流水线唯一信源:链路图 · 命令↔task阶段映射 · 任务目录结构 · 证据清单 · task/目录生命周期所有权。只读参考,不执行动作;6 个 pp-*-v2 技能不再内联链路细节,一律引用本文件。
disable-model-invocation: true
---

# /pp-pipeline — 流水线单一信源(只读参考)

> 改链路 / 目录结构 / 证据约定 / 所有权,**只改本文件**;6 个技能文件只持各自的接口契约。

## 一、唯一链路

```
/pp-clarify-v2 → /pp-plan-v2 → /pp-execute-v2 → /pp-review-v2 → /pp-sync-v2 → /pp-archive-v2
   澄清/根因        方案           执行             审查(+回顾)      同步           归档
```

| 命令 | 阶段 | 定位 |
|---|---|---|
| /pp-clarify-v2 | 澄清/根因 | 四分闸 + 决策点 A/B + 三件产物 · 写 ppwiki clarify |
| /pp-plan-v2 | 方案 | 读三件产物 · 派生 task · 3 份 MD + 子代理模拟验证 |
| /pp-execute-v2 | 执行 | 循环跑命令式验收 → 全绿 |
| /pp-review-v2 | 审查 | 自我攻击 5 维 + 真实测试(附加模块:跨任务回顾) |
| /pp-sync-v2 | 同步 | 提资产入 wiki/decision · 幂等可重跑 · **无 task 阶段** |
| /pp-archive-v2 | 归档 | 写总结 + 物理归档 |

## 二、命令 ↔ task 阶段映射(6 命令 ↔ 5 阶段)

```
根因(clarify) → 方案(plan) → 执行(execute) → 审查(review) → 归档(archive)
sync 无阶段:审查通过后任意时点可重跑(幂等:查重 → update)
```

phase 推进的 op / 参数以 `ppwiki('system --help', {module:'task'})` 为准 · 禁凭记忆。

## 三、生命周期所有权(谁创建 / 谁写 / 谁消费)

| 物 | 创建者 | 写入者 | 消费者 |
|---|---|---|---|
| ppwiki clarify 记录 | clarify(`--create`) | clarify(append / answer / decide / `--lock`) | plan(`--get` 读三件产物) |
| **ppwiki task** | **plan(`clarify --derive_task`:锁定后派生 · 澄清快照入 task · 物理删原澄清)** | execute / review(advance_phase 等) | review --recap · archive(`--archive`) |
| **任务目录 + 证据/** | **clarify(三源调研落证据时创建)** | 各阶段按下行分工 | archive(mv 整目录) |
| 证据/代码证据.md · 外部证据.md | clarify | clarify | plan / review / sync |
| 3 份 MD(对话和澄清 / 验收标准 / 执行方案) | plan | plan | execute / review / sync / archive |
| 证据/执行验收.md | execute | execute | review / sync / archive |
| 证据/审查报告.md | review | review | sync / archive |
| wiki / decision 条目 | sync | sync(查重 → update,幂等) | 后续任务 |
| 任务总结.md + 物理归档目录 | archive | archive | 人 |

## 四、任务目录结构(单源)

```
.pp/wiki/当前任务/[任务名]/
├── 对话和澄清.md / 验收标准.md / 执行方案.md     (plan)
├── 任务总结.md                                   (archive)
├── 澄清.md                                       (仅离线降级模式 · 标「未入库」)
└── 证据/
    ├── 代码证据.md · 外部证据.md                 (clarify)
    ├── 执行验收.md                               (execute)
    └── 审查报告.md                               (review)

归档后 → .pp/wiki/任务归档/[任务名]_YYYY-MM-DD/(冲突加 -rescue-NNN)
```

## 五、移植约定(对齐公约「模块化与移植测试」)

```
每技能三段式:
  ① 接口契约    输入 / 输出 / 缺依赖行为      ─┐
  ② 方法论正文  可移植 · 零 ppwiki             ├─ 移植 = ①② 原样搬走
  ③ Store 接线  ppwiki op 归拢一节            ─┘  + 改写/删除 ③
```

记账点(①②③…)只在 ③ 节映射到具体 op;方法论正文不出现 ppwiki 调用。
