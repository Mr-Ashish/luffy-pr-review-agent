<!-- luffy-review pr=2 run=local-f44 -->
## 🏴‍☠️ Luffy Review — PR #2

**Verdict:** APPROVE  
**Confidence:** high  
**Score:** 90/100  
**Review effort:** 2/5
### Summary
This PR fixes two issues related to the web client’s field handling: preventing crashes in getFieldsSpec when fields are missing, and properly supporting the legacy format: false option in integer and float field extractors. The fixes appear well scoped and targeted to address concrete bugs reported by users, with appropriate guard clauses and option aliasing. Tests for these behaviors are added.
### Walkthrough
- Added guards to skip missing fields in getFieldsSpec to avoid crashes on absent relatedPropertyField (relational_model/utils.js).
- Modified integer and float field extractors to accept format: false as an alias for disabling formatting (integer_field.js and float_field.js).
- Added relevant tests covering the new behaviors (get_fields_spec.test.js).
### Blocking
None
### Key findings
Severity: medium
File: addons/web/static/src/model/relational_model/utils.js
Issue: Defensive checks on missing fields could be expanded
Trigger scenario: When activeFields contains unknown names causing undefined
  lookups
────────────────────────────────────────
Severity: medium
File: addons/web/static/src/views/fields/integer/integer_field.js
Issue: Format alias applied only on integer/float extractors
Trigger scenario: Legacy format: false ignored in other field types if used
────────────────────────────────────────
Severity: medium
File: addons/web/static/src/views/fields/float/float_field.js
Issue: Same as integer_field.js
Trigger scenario: Same as above
### Security audit
No security concerns detected. Changes are internal client-side fixes without new threat surface.
### Suggestions
- Consider adding support for the format: false alias in other field types beyond integer and float, or document explicitly that only these types support that legacy option.
- In utils.js consider logging or warning on missing fields in getFieldsSpec when skipping them silently to aid future debugging.
### Code suggestions
Defensive field lookup improvements (addons/web/static/src/model/relational_model/utils.js)
diff
- if (!fields[activeFieldName]) {
-     continue;
- }
+ if (!fields[activeFieldName]) {
+     console.warn(Field ${activeFieldName} missing in fields spec);
+     continue;
+ }

Why: Logging missing fields could help diagnose symptom causes during debugging.

Additional alias support suggestion (integer_field.js/float_field.js)
diff
- if ('format' in options) {
-     enableFormatting = options.format;
- }
+ if ('format' in options) {
+     enableFormatting = options.format;
+ }
+ // Potential extension: propagate same alias to other fields if applicable

Why: Uniform behavior for legacy formatting disablement may improve consistency.
### Nits
- Minor code style consistent with existing conventions.
- Test messages could explicitly mention the associated GH issues.
### Tests & risk
- Relevant tests added/updated: yes
- Coverage: Covers missing field skips and alias acceptance for format option
- Risk: low — focused patches that fix specific bugs without broad behavior shifts
- Rollback: easy
### What I checked
- Full diff of utils.js, integer_field.js, float_field.js, and new tests
- Verified no unrelated or risky changes included
- Confirmed test coverage added for new code


Luffy · Hermes Agent · OpenRouter · memory-backed review
