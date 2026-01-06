# CoAuthor UI Redesign - Detailed Implementation Strategy

**Document:** Implementation Playbook
**Date:** December 29, 2025
**Status:** Ready for Phase 3-8 Execution

---

## Executive Summary

The exploration phase (Phases 1-2) has been completed successfully. We have:

1. **Mapped the complete VSCodium codebase** - 294 CSS files, identified 18 priority modification files
2. **Analyzed the CoAuthor extension architecture** - React webview + Tailwind CSS with 10 modification points
3. **Created detailed architectural blueprints** - All components, integration points, and data flows documented

**Path Forward:** Clean, surgical implementation of Phases 3-8 using multi-stage parallel execution strategy.

---

## Phase-by-Phase Implementation Strategy

### PHASE 3: Design System & Tokens (CURRENT)

**Objective:** Create reusable design system before implementing visual changes

**Tasks:**

1. **Create Design Tokens File** (new file: `src/design-system/tokens.ts`)
   - Color palette definition
   - Typography scale
   - Spacing/sizing system
   - Shadow definitions
   - Animation timing

2. **Create CSS Variables File** (new file: `src/design-system/variables.css`)
   - CSS custom properties from tokens
   - Light/dark theme variants
   - Component-scoped variables
   - Fallback values

3. **Tailwind Configuration for Extension** (modify: `extensions/coauthor-agent/tailwind.config.js`)
   - Custom theme colors
   - Typography scale
   - Spacing values
   - Component configurations

**Deliverables:**
- [ ] `design-system/tokens.ts` - Centralized token definitions
- [ ] `design-system/variables.css` - CSS custom properties
- [ ] Updated Tailwind config with wireframe colors
- [ ] Design system documentation

**Estimated Duration:** 2-3 hours

---

### PHASE 4: Sidebar & Navigation Styling

**Objective:** Refactor left sidebar to match wireframe design

**Key Changes:**

1. **Sidebar Width & Layout** (modify: `src/vs/workbench/browser/media/sidebar.css`)
   - Adjust width to 250-300px (from wireframes)
   - Update background colors using design tokens
   - Refine border styling
   - Update padding/margins

2. **Tree Item Styling** (modify: sidebar tree CSS)
   - Font sizing and weight (from design system)
   - Hover/active states
   - Indentation levels
   - Icon sizing

3. **Section Headers** (Typography)
   - "SOURCE CONTROL" header styling
   - "Manuscript" tree section
   - "Characters" section
   - "Research" section
   - Update colors and typography

4. **Activity Bar Icon** (modify: `extensions/coauthor-agent/assets/icons/icon.svg`)
   - Replace with new professional icon
   - Ensure 48x48px dimensions
   - Update for light/dark themes

**Files to Modify:**
```
- src/vs/workbench/browser/media/sidebar.css (main changes)
- src/vs/workbench/browser/parts/sidebar/sidebarpart.css
- src/vs/workbench/browser/media/workbench.css (global sidebar vars)
- extensions/coauthor-agent/assets/icons/icon.svg (new design)
```

**Estimated Duration:** 3-4 hours

---

### PHASE 5: Main Editor Area Styling

**Objective:** Refactor editor styling for document-focused writing experience

**Key Changes:**

1. **Editor Canvas Styling** (modify: `src/vs/editor/browser/media/editor.css`)
   - Font family and size (from design system)
   - Line height and letter spacing
   - Background color
   - Text color and selection styling

2. **Editor Margins/Padding** (Editor layout)
   - Add document margins
   - Center text in editor (reading-width constraint)
   - Update ruler and line number styling

3. **Editor Tab Styling** (modify: `src/vs/workbench/browser/media/editorstatus.css`)
   - Tab bar background
   - Tab item styling (active/inactive)
   - Font sizing and weight
   - Hover/active state colors

4. **Editor Title Bar** (modify: editor title CSS)
   - Breadcrumb styling
   - File name display
   - Formatting toolbar styling (B, I, H1, H2, etc.)
   - Ensure toolbar items are visible and clickable

5. **Editor Status Bar** (right-side indicators)
   - Language indicator
   - Encoding display
   - Line/column display
   - Styling with design tokens

**Files to Modify:**
```
- src/vs/editor/browser/media/editor.css
- src/vs/workbench/browser/media/editorstatus.css
- src/vs/workbench/browser/parts/editor/editorgroups.css
- src/vs/workbench/browser/media/editorpane.css
```

**Estimated Duration:** 4-5 hours

---

### PHASE 6: Co-pilot Right Sidebar Panel

**Objective:** Update extension UI to match wireframe design

**Key Changes:**

1. **Webview Styling Updates** (modify: `extensions/coauthor-agent/webview-ui/build/assets/index.css`)
   - Update Tailwind theme colors
   - Message styling (user/assistant messages)
   - Input field styling
   - Button styling and hover states
   - Mention badges styling
   - Slash command highlighting

2. **React Component Updates** (modify: extension React source)
   - Message component styling
   - Input component styling
   - Button component styling
   - Conversation UI layout
   - Scrollbar styling

3. **Color Scheme** (Tailwind config + CSS)
   - Primary color (professional blue from wireframe)
   - Suggestion color (yellow highlight for AI suggestions)
   - Background colors
   - Text colors
   - Border colors

4. **Typography** (from design system)
   - Font sizes for messages
   - Font weights
   - Line heights
   - Letter spacing

5. **Spacing & Layout** (CSS Grid/Flexbox)
   - Message spacing
   - Input field padding
   - Button sizing
   - Panel margins

6. **Animations** (keyframes)
   - Message appearance animation
   - Typing indicator animation
   - Button hover animation

**Files to Modify:**
```
- extensions/coauthor-agent/webview-ui/build/assets/index.css (main styling)
- extensions/coauthor-agent/src/ (React components - if extracting from dist)
- extensions/coauthor-agent/tailwind.config.js (theme configuration)
```

**Estimated Duration:** 3-4 hours

---

### PHASE 7: Corkboard View Implementation

**Objective:** Create new Corkboard panel for project/scene organization

**Key Features:**

1. **Corkboard Panel Component** (new)
   - Create new webview or panel contribution
   - Register in extension manifest
   - Create tab toggle between "Editor" and "Corkboard"
   - Implement card grid layout

2. **Card Component System**
   - Card container with border and shadow
   - Title section
   - Description section
   - Status badge
   - Menu icon (three dots)
   - Rounded corners, subtle styling

3. **Grid Layout**
   - Responsive grid (3 cards per row from wireframe)
   - Card sizing (fixed or responsive)
   - Spacing between cards
   - "Add" button with "+" icon

4. **Functionality**
   - Create new card button
   - Edit card (open in editor)
   - Delete card
   - Drag/drop reordering (optional)
   - Status indicators (M, U, D from git view)

5. **Styling**
   - Use design tokens for colors
   - Card elevation with shadow
   - Button styling matching sidebar
   - Typography from design system

**Implementation Approach:**

Option A (Simpler): Webview-based panel
- Create React component in extension
- Tab navigation (Editor/Corkboard)
- Communicate with backend via postMessage

Option B (Complex): Workbench contribution
- Create workbench panel component
- Integrate with existing panel system
- Use workbench services

**Recommended:** Option A (simpler, faster)

**Files to Create/Modify:**
```
- extensions/coauthor-agent/src/corkboard/CorkboardPanel.tsx (new)
- extensions/coauthor-agent/package.json (add view contribution)
- extensions/coauthor-agent/webview-ui/src/components/Corkboard.tsx (new)
```

**Estimated Duration:** 5-6 hours

---

### PHASE 8: Testing & Polish

**Objective:** Validate implementation and ensure quality

**Tasks:**

1. **Responsive Design Testing**
   - Test at multiple viewport sizes (1024px, 1440px, 1920px+)
   - Ensure all components scale properly
   - Check sidebar collapsing
   - Verify editor reflow

2. **Theme Testing**
   - Dark mode validation
   - Light mode validation
   - High contrast mode validation
   - Color contrast accessibility (WCAG AA)

3. **Cross-Platform Testing**
   - macOS validation
   - Windows validation
   - Linux validation
   - Font rendering consistency

4. **Performance Validation**
   - CSS file size optimization
   - Bundle size check
   - Rendering performance
   - Scroll performance

5. **Accessibility Audit**
   - Keyboard navigation
   - Screen reader testing
   - Focus management
   - Color contrast verification

6. **Visual Regression Testing**
   - Compare against wireframes
   - Screenshot comparison
   - Layout alignment
   - Spacing consistency

7. **Browser/Extension Compatibility**
   - VS Code version compatibility (^1.84.0)
   - Extension loading verification
   - API compatibility check

**Estimated Duration:** 4-5 hours

---

## Parallel Execution Strategy

### Stage 1: Foundation (Parallel)
- [ ] Create design tokens (Phase 3)
- [ ] Analyze current CSS architecture in detail

**Duration:** 2-3 hours
**Execution:** Single focused effort

---

### Stage 2: Core UI Transformation (Parallel)
Execute Phases 4-6 in parallel (minimal dependencies):

**Track A: VSCodium Core**
- [ ] Phase 4: Sidebar styling refactor
- [ ] Phase 5: Editor area styling

**Track B: Extension UI**
- [ ] Phase 6: Co-pilot panel updates

**Dependencies:** All depend on Phase 3 (design tokens)

**Duration:** 4-5 hours (parallel execution reduces serial time)
**Execution:** 2-3 agents working in parallel

---

### Stage 3: New Features
- [ ] Phase 7: Corkboard view implementation

**Dependencies:** Phase 3 (design tokens)

**Duration:** 5-6 hours
**Execution:** Single focused effort

---

### Stage 4: Validation & Polish
- [ ] Phase 8: Testing and polish

**Dependencies:** Phases 3-7 must be complete

**Duration:** 4-5 hours
**Execution:** Single comprehensive audit

---

## Total Timeline

**Sequential (naive approach):** 26-32 hours
**With parallel execution:** 15-18 hours
**With optimal parallelization:** 11-14 hours

**Recommended approach:** Use multiple agents in parallel for Stages 1-3, then validate with Stage 4.

---

## Critical Success Factors

### Code Quality
✅ **Clean, surgical modifications only**
- Minimal breaking changes
- Use existing component systems
- Follow VSCodium coding standards
- Maintain backward compatibility

✅ **Design System Driven**
- Single source of truth for colors, typography, spacing
- Reusable tokens
- Consistent across VSCodium + Extension

✅ **Documentation**
- Document all custom CSS
- Comment on non-obvious changes
- Maintain design system docs
- Track changes for maintenance

### Technical Execution
✅ **Incremental validation**
- Build watch task running (`VS Code - Build` task)
- Check compilation after each phase
- Test in actual VS Code/VSCodium instance
- Verify no regressions

✅ **Version control**
- Commit after each phase
- Clear commit messages with "WIP: UI Redesign" prefix
- Create feature branch
- Easy rollback capability

---

## Risk Mitigation

### Potential Issues

| Risk | Severity | Mitigation |
|------|----------|-----------|
| CSS specificity conflicts | High | Use design tokens, avoid !important |
| Extension incompatibility | High | Test extension loading after each phase |
| Performance regression | Medium | Monitor bundle size, CSS file size |
| Cross-platform font rendering | Medium | Use system fonts, fallback stacks |
| Dark/light theme issues | Medium | Test both themes during Phase 8 |
| Missing responsive breakpoints | Low | Test at common viewport sizes |

### Rollback Strategy

Each phase is self-contained:
- If Phase 4 fails → Revert sidebar CSS only
- If Phase 6 fails → Revert extension CSS only
- No cumulative dependency issues

---

## Execution Readiness Checklist

**Pre-Flight:**
- [x] Codebase fully explored and documented
- [x] Extension architecture analyzed
- [x] Wireframe requirements extracted
- [x] Implementation plan created
- [x] Parallel execution strategy defined

**Ready to Proceed:** ✅ YES

**Next Action:** Begin Phase 3 (Design Tokens) with full context

---

## Agent Task Allocation

### Single-Agent Tasks (Phases 3, 7, 8)
- Agent 1: Phase 3 (Design System & Tokens)
- Agent 2: Phase 7 (Corkboard Implementation)
- Agent 3: Phase 8 (Testing & Polish)

### Parallel Tasks (Phase 4-6)
- Agent 4: Phase 4 (Sidebar Styling)
- Agent 5: Phase 5 (Editor Styling)
- Agent 6: Phase 6 (Co-pilot Panel)

---

## Continuation Instructions

### For Implementing Phases 3-8

1. **Update progress document** with each completed phase
2. **Commit after each phase** to maintain version control
3. **Run build watch task** before any modifications
4. **Check compilation errors** before declaring phase complete
5. **Test in running VS Code instance** whenever possible
6. **Update todo list** as work progresses

### Key Commands

```bash
# Monitor compilation
npm run watch-clientd
npm run watch-extensionsd

# Run tests
./scripts/test.sh

# Run dev instance
./scripts/code.sh

# Check for CSS errors
grep -r "syntax error" out-vscode/
```

### Success Criteria

- ✅ All code compiles without errors
- ✅ Extension loads successfully in VS Code
- ✅ UI matches wireframe designs
- ✅ No visual regressions in other areas
- ✅ Responsive design works at all viewport sizes
- ✅ Dark and light themes both functional
- ✅ All tests pass

---

**Document Version:** 1.0
**Last Updated:** 2025-12-29
**Status:** Ready for Phase 3 Execution
