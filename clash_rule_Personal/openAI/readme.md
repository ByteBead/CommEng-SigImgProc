# clash的openAI规则

为了chatGPT能够正常运行，并单独控制节点的使用，即日起我开始维护一个独立的规则**openAI.yaml**。

如果你使用的软件也是clash，那么还需如下的设置:

+ 在rule-providers下添加如下源:

```yaml
 openAI: { type: http, behavior: classical, url: 'https://github.com/ComTechCo/case-base-for-Communication-engineering-students/blob/master/clash_rule_Personal/openAI/openAI.yaml', path: ./ruleset/openAI.yaml, interval: 86400 }
```

+ 在rules添加如下规则:

```yaml
    - 'RULE-SET,openAI,openAI'
```

