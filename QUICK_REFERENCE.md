# CoAuthor UI Redesign - Quick Reference Guide

**For:** Developers implementing Phases 3-8
**Date:** December 29, 2025

---

## Files You'll Modify (By Priority)

### CRITICAL - Global Impact
```
1. src/vs/workbench/browser/media/workbench.css
   ↳ Global fonts, colors, animations, variables
   ↳ Changes affect entire application

2. product.json
   ↳ Default editor settings, fonts
   ↳ Changes affect first-run experience
```

### HIGH - Component Styling
```
3. src/vs/workbench/browser/media/sidebar.css
   ↳ Left sidebar appearance

4. src/vs/editor/browser/media/editor.css
   ↳ Main editor text rendering

5. src/vs/workbench/browser/media/editorstatus.css
   ↳ Editor tabs and title bar

6. extensions/coauthor-agent/webview-ui/build/assets/index.css
   ↳ Co-pilot panel styling
```

### MEDIUM - Layout Components
```
7. src/vs/workbench/browser/media/parts.css
   ↳ Part container sizing

8. src/vs/workbench/browser/media/panel.css
   ↳ Bottom panel (terminal, debug)

9. src/vs/workbench/browser/media/statusbar.css
   ↳ Bottom status bar
```

### LOW - Assets & Configuration
```
10. extensions/coauthor-agent/assets/icons/icon.svg
    ↳ Activity bar icon

11. extensions/coauthor-agent/tailwind.config.js
    ↳ Tailwind theme customization

12. extensions/coauthor-agent/package.json
    ↳ Contribution points, commands, views
```

---

## Key CSS Variables to Create (Phase 3)

### Colors
```css
/* Primary Brand Colors */
--color-primary: #0066CC;        /* Professional blue */
--color-primary-hover: #0052A3;
--color-primary-active: #003D7A;

/* Backgrounds */
--color-bg-primary: #FFFFFF;     /* Light mode */
--color-bg-secondary: #F5F5F5;
--color-bg-editor: #FAFAFA;
--color-bg-dark: #1E1E1E;        /* Dark mode */

/* Text */
--color-text-primary: #1F2937;   /* Main text */
--color-text-secondary: #6B7280; /* Secondary text */
--color-text-light: #D4D4D4;     /* Dark mode text */

/* Accents */
--color-accent-suggestion: #FEF3C7; /* Yellow for AI suggestions */
--color-accent-error: #DC2626;
--color-accent-success: #10B981;
--color-accent-warning: #F59E0B;

/* Borders */
--color-border: #E5E7EB;
--color-border-dark: #404040;
```

### Typography
```css
/* Font Families */
--font-ui: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
--font-editor: 'SF Mono', Monaco, 'Inconsolata', 'Fira Mono', monospace;
--font-manuscript: 'Azeret Mono', 'SF Mono', monospace;

/* Font Sizes */
--fs-xs: 11px;
--fs-sm: 12px;
--fs-base: 13px;
--fs-lg: 14px;
--fs-xl: 16px;
--fs-2xl: 18px;
--fs-3xl: 20px;

/* Line Heights */
--lh-tight: 1.2;
--lh-normal: 1.5;
--lh-relaxed: 1.625;
```

### Spacing
```css
/* Baseline 4px spacing */
--spacing-1: 4px;
--spacing-2: 8px;
--spacing-3: 12px;
--spacing-4: 16px;
--spacing-6: 24px;
--spacing-8: 32px;
```

---

## Component Styling Patterns

### From Wireframe Analysis

**Sidebar:**
- Width: 250-300px
- Background: Clean white (#FFFFFF) or dark (#1E1E1E)
- Text: Professional sans-serif, 13px
- Icons: Codicons (500+ available)
- Tree items: Left indent 12px per level
- Hover state: Subtle background highlight

**Editor:**
- Font: System monospace (14px)
- Line height: 1.5
- Word wrap: ON (manuscript setting)
- Line numbers: OFF (manuscript setting)
- Minimap: Hidden (manuscript setting)
- Selection: Blue highlight with alpha transparency
- Cursor: Smooth blinking

**Co-pilot Panel:**
- Message styling: Clean text with author indicator
- Input field: Minimal border, focus highlight
- Mentions: @file format with badge styling
- Slash commands: Autocomplete with suggestions
- Buttons: Flat design with hover state

**Corkboard:**
- Cards: Rounded corners (8px), subtle shadow
- Card width: ~300px (3 per row)
- Spacing: 16px between cards
- Title: Bold, 16px
- Description: Regular, 13px, gray
- Status badge: Small pill-shaped indicator

---

## Build & Validation Workflow

### Before Starting Any Work
```bash
# 1. Ensure build task is running
Run Task → VS Code - Build

# 2. Check for existing errors
Check Build output for any compilation errors

# 3. Start dev instance (in another terminal)
./scripts/code.sh
```

### After Each Phase
```bash
# 1. Monitor build output
Check "Core - Build" and "Ext - Build" tasks for errors

# 2. Fix any compilation errors immediately
Don't proceed if errors exist

# 3. Test in running VS Code
Make changes → Save → View in dev instance
Verify visual changes match wireframes

# 4. Commit your work
git commit -m "Phase X: [component] - [description]"
```

### Before Declaring Phase Complete
- [ ] No compilation errors in build output
- [ ] Visual changes match wireframe design
- [ ] No console errors in VS Code
- [ ] Extension loads successfully
- [ ] Dark and light themes both work
- [ ] Responsive layout looks good

---

## Extension Modification Quick Guide

### To Update Co-pilot Panel Styling

**Option 1: Direct CSS Edit (Recommended)**
```
File: extensions/coauthor-agent/webview-ui/build/assets/index.css

Approach:
1. Find relevant class (e.g., ".chat-message", ".input-field")
2. Update color properties to use design tokens
3. Update sizing from spacing system
4. Test in running instance
```

**Option 2: Tailwind Theme Edit**
```
File: extensions/coauthor-agent/tailwind.config.js

Approach:
1. Update theme.colors section
2. Update theme.spacing section
3. Rebuild: npm run build-webview (from extension dir)
4. Verify index.css regenerated correctly
```

### To Update Toolbar Buttons

```
File: extensions/coauthor-agent/package.json

Under "contributes.commands":
- Modify command icons, labels, when conditions
- Icons can reference: $(iconName) syntax
- Test with palette commands (Ctrl/Cmd + Shift + P)
```

### To Add New Views/Panels

```
File: extensions/coauthor-agent/package.json

Add to "contributes.viewsContainers":
{
  "id": "corkboard",
  "title": "Corkboard",
  "icon": "assets/icons/corkboard.svg"
}

Add to "contributes.views":
{
  "corkboard": [{
    "type": "webview",
    "id": "claude-dev.CorkboardPanel",
    "name": "Corkboard",
    "when": "view == corkboard"
  }]
}

In extension.ts:
vscode.window.registerWebviewViewProvider(
  'claude-dev.CorkboardPanel',
  new CorkboardPanelProvider(context)
)
```

---

## Common CSS Modifications

### Update Colors Globally
```css
/* Old: Direct color value */
.sidebar { background-color: #252526; }

/* New: Use CSS variable */
.sidebar { background-color: var(--color-bg-secondary); }
```

### Update Typography Globally
```css
/* Old: Direct values */
.editor { font-family: 'Monaco'; font-size: 14px; }

/* New: Use variables */
.editor { font-family: var(--font-editor); font-size: var(--fs-lg); }
```

### Update Spacing Globally
```css
/* Old: Direct values */
.sidebar { padding: 16px; margin: 8px; }

/* New: Use spacing system */
.sidebar { padding: var(--spacing-4); margin: var(--spacing-2); }
```

### Add Theme Support
```css
/* Use prefers-color-scheme for automatic theme switching */
@media (prefers-color-scheme: dark) {
  .component {
    background: var(--color-bg-dark);
    color: var(--color-text-light);
  }
}
```

---

## Testing Checklist

### Visual Testing
- [ ] Sidebar width and styling match wireframe
- [ ] Editor font and layout match wireframe
- [ ] Co-pilot panel colors and typography match
- [ ] Corkboard cards display correctly
- [ ] All text is readable (color contrast)
- [ ] Icons are properly sized and aligned

### Functional Testing
- [ ] Sidebar trees expand/collapse
- [ ] Editor text renders and wraps correctly
- [ ] Co-pilot input accepts text and mentions
- [ ] Commands execute from toolbar
- [ ] Dark/light theme toggle works
- [ ] Extension loads without errors

### Responsive Testing
- [ ] Layout works at 1024px width
- [ ] Layout works at 1440px width
- [ ] Layout works at 1920px+ width
- [ ] Sidebar collapses on small screens
- [ ] Editor reflows correctly
- [ ] Panel resizes correctly

---

## Key Contacts/Resources

### Documentation References
- `progress_ui_redesign_251229.md` - Main progress document
- `IMPLEMENTATION_STRATEGY.md` - Detailed phase guide
- VS Code Extension API: https://code.visualstudio.com/api
- VS Code Theme Colors: https://code.visualstudio.com/docs/getstarted/theme-color-reference

### Wireframe References
- `wireframes/1_Main_Wireframe.png` - Editor view target design
- `wireframes/2_Corkboard_Wireframe.png` - Corkboard view target design
- `wireframes/3_Commit_Wireframe.png` - Source control view target design

---

## Quick Debugging Tips

### Extension Not Loading
```bash
# Check in VS Code console (Help → Toggle Developer Tools)
# Look for errors in browser devtools
# Verify package.json syntax (JSON validator)
```

### CSS Changes Not Showing
```bash
# Hard refresh in VS Code
Ctrl/Cmd + Shift + P → Developer: Reload Window

# Check CSS file was saved
# Monitor build task for compilation errors
```

### Colors Not Updating
```bash
# Verify CSS variables are defined in global scope
# Check for specificity issues (use :root or html selector)
# Use !important only as last resort for testing
```

### Extension Crashes
```bash
# Check console for JavaScript errors
# Verify postMessage communication format
# Check VS Code version compatibility (^1.84.0)
```

---

## Success Criteria Summary

✅ **Code Quality**
- Clean, surgical modifications only
- Uses design system tokens
- Well-commented non-obvious changes
- Follows existing code patterns

✅ **Visual Quality**
- Matches all three wireframes
- Professional appearance
- Consistent spacing and typography
- Dark/light theme support

✅ **Technical Quality**
- Compiles without errors
- Extension loads successfully
- No console errors
- Responsive at all viewport sizes

✅ **Maintainability**
- Design tokens centralized
- CSS organized logically
- Changes documented
- Easy to modify in future

---

**Version:** 1.0
**Last Updated:** 2025-12-29
**Status:** Ready for Implementation
