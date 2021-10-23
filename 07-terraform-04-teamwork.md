# server.yaml  

```
repos:
- id: /.*/
  branch: /.*/
  apply_requirements: [approved, mergeable]
  workflow: custom
  allowed_overrides: [apply_requirements, workflow, delete_source_branch_on_merge]
  allowed_workflows: [custom]
  allow_custom_workflows: true
  delete_source_branch_on_merge: true
  pre_workflow_hooks: 
    - run: my-pre-workflow-hook-command arg1
- id: github.com/myorg/specific-repo
workflows:
  custom:
    plan:
      steps:
      - run: my-custom-command arg1 arg2
      - init
      - plan:
          extra_args: ["-lock", "false"]
      - run: my-custom-command arg1 arg2
    apply:
      steps:
      - run: echo hi
      - apply
	  }
```

