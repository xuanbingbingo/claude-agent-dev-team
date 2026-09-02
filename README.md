# Agent 应用开发团队（Claude Code）

一套面向 **LLM Agent / 智能体应用** 的 Claude Code Subagent 团队。核心不是"把功能写完"，而是 **Eval 驱动迭代收敛**——先定义"怎么算做对了"，再动手；每改一次，跑一次评估集回归。

> 这不是标准开发团队的换皮版。CRUD 类项目需求可枚举成接口，写完就算完；**agent 类项目需求天生模糊，"好不好用"要跑出来才知道**。所以这套团队的核心契约不是 API_CONTRACT，而是 `CAPABILITY_PROFILE`（能力画像）+ `EVAL_SPEC`（怎么算赢）。

---

## 一句话铁律

> **没有 eval，不许改 prompt、不许换模型。**
> 评估是裁判，开发是运动员，两者不能是同一个人。

这套团队里 `agentapp-eval-lead` 被显式禁止碰 prompt 和工具代码——它只定标尺、只做裁判。这是刻意的设计：让"改完自我感觉良好"这件事在流程上不成立。

---

## 它能做什么

输入一句「用 agent 团队开发一个 XXX」，主对话作为总指挥，自动按顺序调度成员 agent：

```
场景识别 → 能力画像 + Eval 设计（两人并列站最前）
→ 系统设计 + Eval 集     → Context 工程 + Trace 规范
→ 最小可跑骨架           → ★ Eval 驱动迭代循环 ★（跑评估 → 定位根因 → 打回 → 回归）
→ 安全审查（注入/越权/泄露）→ 最终验收（含新鲜 case 防过拟合）→ 文档
```

适用形态：工具型 agent、RAG 问答、多智能体系统、AI 助手、对话式产品后端。

还支持 **Audit 模式**——已经有一个跑得不好的 agent，说「审查这个 agent」，团队会逆向出能力画像 + 诊断 eval 缺口。实践中头两号病根几乎总是同样两条：**没有 eval**、**没有 trace**。

---

## 安装

### 一键安装（推荐）

```bash
git clone https://github.com/xuanbingbingo/claude-agent-dev-team.git
cd claude-agent-dev-team
bash install.sh
```

脚本会**自动检测你是否已经装过其他 Claude 团队**（标准团队 / 小程序团队等）：

| 你的情况 | 安装行为 |
|---|---|
| 没装过其他团队 | 安装全部 8 个 agent，开箱即用 |
| 已装过其他团队 | 只补 7 个专属 agent；共用的 `technical-writer` 保持你现有版本，**不覆盖** |

其他用法：

```bash
bash install.sh --force       # 强制覆盖所有同名 agent（用最新版）
bash install.sh --uninstall   # 卸载（只删专属 agent + skill，不动共用 agent）
```

### 验证

```bash
ls ~/.claude/agents/ | grep agentapp      # 应看到 7 个 agentapp-* agent
ls ~/.claude/skills/agent-dev-team/SKILL.md
```

重启 Claude Code，新开对话输入：

```
用 agent 团队开发一个能查公司内部文档的问答助手
```

主对话会 load `agent-dev-team` skill 接管，先让 architect 走场景识别决策树，等你确认方向后继续。

---

## 团队成员

7 个专属 agent + 1 个共用 agent。

### 定义层（站最前，两人并列）

| Agent | 职责 |
|---|---|
| `agentapp-architect` | **场景识别决策树** → 能力画像；workflow-vs-agent 选型；编排 / 模型 / context / memory 架构 |
| `agentapp-eval-lead` | **灵魂角色**。把能力画像翻译成度量层；产出 eval 集 / 断言 / 成功指标 / 红线；全程回归裁判 |

### 构建层

| Agent | 职责 |
|---|---|
| `agentapp-builder` | **Context Engineering 合一**：system prompt + tool/function 定义 + RAG 检索 + memory 拼装 |
| `agentapp-runtime` | agent runtime、会话状态、流式、**tracing 可观测性**、API 编排落地 |

### 质量层

| Agent | 职责 |
|---|---|
| `agentapp-safety` | prompt injection / 工具越权 / guardrails / 数据泄露，与 eval-lead 合出 safety eval |
| `agentapp-reality-checker` | 上线前整体验收，**必须用未进评估集的新鲜 case 复验**，防对着 eval 过拟合 |

### 可选层

| Agent | 触发条件 |
|---|---|
| `agentapp-frontend` | 仅当交付形态含对话 UI（流式渲染 / 工具调用过程可视化 / 引用来源展示）。纯 API 服务不上 |
| `technical-writer` | 需要交付文档时（与其他团队共用） |

---

## 与标准团队的根本区别

| 维度 | standard-team（标准开发团队） | **agent-dev-team（本团队）** |
|---|---|---|
| 需求形态 | 明确、可枚举成接口 | **天生模糊**，"好不好用"要跑出来才知道 |
| 核心契约 | API_CONTRACT（接口定死） | **CAPABILITY_PROFILE + EVAL_SPEC** |
| 编排范式 | 线性瀑布 11-Phase | **场景识别 → 最小可跑 → Eval 驱动循环** |
| 质量机制 | 任务级 Dev-QA Loop（静态核查） | **Eval Loop（跑评估集 + 读 trace 回归）** |
| 退出条件 | 所有任务 `[x]` | **eval 红线全过 + 成功指标达标 + 无回退** |
| 灵魂角色 | software-architect（定契约） | **eval-lead（定"怎么算赢"）与 architect 并列** |

两套可以同时装，互不冲突。项目是 CRUD 就走标准团队，是 agent 就走这套。

---

## 几个刻意的设计取舍

**1. 反过度设计闸门**
architect 判定"其实一个固定 workflow 就够，不需要 autonomous agent"或"单 agent 足够，不需要多智能体"——**这是正确产出，不是偷懒**。总指挥被要求支持降配，禁止为了看起来高级硬上多 agent。

**2. 没有 trace 不许进迭代**
runtime 的一等交付物是 `TRACE_SPEC.md`。每步的输入 context、模型输出、工具调用参数与返回、token、耗时、失败原因都要能回放。没有 trace，debug 全靠猜，eval 挂了也说不出挂在哪一步。

**3. 止损规则写进流程**
某指标连续 3 轮不升反降或原地踏步 → 暂停，回到 Phase 1-2 重审能力画像。**这是特性不是 bug**：eval 循环最有价值的一件事，就是能暴露"需求本身没想清楚"。

**4. 验收官必须用新鲜 case**
一个只在自己题库上拿高分的 agent 不算合格。reality-checker 默认判决是 NEEDS WORK，只有压倒性证据才判 READY。

**5. 安全红线一票否决**
越权 / 注入 / 泄露任意一条挂 = 不许上线，且修完要补一条 safety eval 进 EVAL_SPEC 防回归。

---

## 产出的契约文件

```
docs/
  CAPABILITY_PROFILE.md   ★核心契约★ 场景 5 维判定 → 能力画像 + 验收维度
  EVAL_SPEC.md            ★核心契约★ eval 数据集 / 断言 / 成功指标 / 红线场景
  AGENT_SPEC.md           编排模式 / 模型选型 / context 架构 / memory / 停止条件
  PROMPT_SPEC.md          system prompt 全文 / 角色设定 / 输出结构
  TOOL_CONTRACT.md        工具定义（名 / 参数 schema / 返回 / 错误 / 示例）
  RAG_SPEC.md             仅当画像标注"需外部知识"才生成
  TRACE_SPEC.md           可观测性：每步 trace 必须记录的字段
  EVAL_REPORT.md          每轮迭代 eval 结果累计（含↑↓对比）
  SAFETY_REPORT.md        安全审查报告
  ACCEPTANCE_REPORT.md    最终验收报告
agent-tasks/
  build-tasklist.md       构建任务清单（能力单元维度，非接口维度）
  iteration-log.md        每轮循环：改了什么 → 指标变化 → trace 定位到的根因
```

---

## 完整流程文档

每个 Phase 的详细输入 / 产出 / 打回规则，见 [`skills/agent-dev-team/SKILL.md`](skills/agent-dev-team/SKILL.md)（这也是主对话实际加载的总指挥剧本）。

---

## 常见问题

**Q：和标准团队 / 小程序团队能同时装吗？**
能。共用 agent 只有一份，各套 skill 独立，互不冲突。

**Q：为什么总指挥是 skill 不是 agent？**
Claude Code 平台限制——subagent 不能再 spawn subagent，Task 工具会被运行时强制剥离。所以总指挥必须由主对话亲自担任，以 skill 形式装载剧本。

**Q：eval 集要我自己写吗？**
不用。`agentapp-eval-lead` 会根据能力画像自动生成，覆盖 happy path + 边界 + 红线场景，每条标注断言方式（精确匹配 / 结构校验 / LLM-as-judge / 工具调用轨迹校验）。你要做的是在 Phase 2 检查点看一眼达标线合不合理。

**Q：我的项目其实不需要 agent，只要一个固定流程呢？**
那 architect 会直接告诉你"用 workflow 就够"，并按 workflow 出方案。这个团队的第一道闸门就是防止过度设计。

**Q：能在 Cursor / Cline 用吗？**
不能。依赖 Claude Code 的 Subagents 机制。

---

## 相关团队

| 仓库 | 适用场景 |
|---|---|
| [claude-standard-dev-team](https://github.com/xuanbingbingo/claude-standard-dev-team) | 中型 Web 应用，需求明确可枚举成接口 |
| [claude-miniprogram-team](https://github.com/xuanbingbingo/claude-miniprogram-team) | 微信小程序 + 后端 |
| **claude-agent-dev-team**（本仓库） | LLM Agent / 智能体应用，Eval 驱动 |

---

## License

MIT
