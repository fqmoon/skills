# 仓库规则

本仓库的每个 `SKILL.md`（含 `archive/`）frontmatter 必须同时有这两项，缺一不可：

```yaml
license: MIT
metadata:
  author: "fqmoon (https://github.com/fqmoon)"
```

- `author` 是字符串，值固定为上面这一行。不写邮箱，不写成对象，不加别的联系方式。
- `license` 只标许可种类。版权声明和 MIT 全文在仓库根的 `LICENSE`，不要抄进正文，也不要写在 frontmatter 前面。
- frontmatter 必须从文件第一行的 `---` 开始。
