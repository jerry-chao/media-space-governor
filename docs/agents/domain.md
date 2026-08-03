# Domain docs

This repo uses a single-context domain-doc layout.

## Layout

- Root glossary: `CONTEXT.md`
- Architecture decisions: `docs/adr/`

## Consumer rules

- Read `CONTEXT.md` before producing specs, designs, or implementation plans in this repo
- Use the glossary vocabulary from `CONTEXT.md` consistently
- Respect ADRs in `docs/adr/` when making or documenting decisions
- Create new ADRs under `docs/adr/` only when a decision is hard to reverse, surprising without context, and the result of a real trade-off
- Treat `CONTEXT.md` as glossary-only documentation, not as an implementation spec
