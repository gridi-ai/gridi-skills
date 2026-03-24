# Figma MCP Command Guide

Uses karthiks3000/figma-mcp-server to read, create, and modify Figma designs.

## Setup

### 1. Install MCP Server (install in `~/.claude`, not the project folder)

```bash
cd ~/.claude
git clone https://github.com/karthiks3000/figma-mcp-server.git
cd figma-mcp-server
npm install
npm run build
```

### 2. Claude Code MCP Configuration

`~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "figma": {
      "command": "node",
      "args": ["~/.claude/figma-mcp-server/dist/index.js"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "your_figma_token"
      }
    }
  }
}
```

### 3. Install Figma Plugin (for write mode)

1. Launch Figma Desktop app
2. Plugins > Development > Import plugin from manifest
3. Select `~/.claude/figma-mcp-server/figma-plugin/manifest.json`
4. Run the plugin to establish WebSocket connection

### Generating a Personal Access Token

1. Go to Figma → Profile icon → **Settings**
2. **Security** tab → "Personal access tokens"
3. Click **Generate new token**
4. Grant "File content" and "Dev resources" read permissions
5. Copy the token

---

## Read Tools (Readonly Tools)

### VALIDATE_TOKEN

Verify Figma file access permissions

```javascript
mcp_figma_validate_token({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign"
})
```

### GET_FILE_INFO

Retrieve file metadata

```javascript
mcp_figma_get_file_info({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign"
})
// Returns: file name, page list, last modified date, etc.
```

### GET_NODE_DETAILS

Retrieve detailed node information

```javascript
mcp_figma_get_node_details({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign",
  "nodeId": "1234:5678",           // Optional
  "detailLevel": "full",          // summary | basic | full
  "properties": ["fills", "strokes", "effects"]  // Optional
})
// Returns: node hierarchy, styles, Auto Layout, etc.
```

### EXTRACT_STYLES

Extract design styles

```javascript
mcp_figma_extract_styles({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign"
})
// Returns: color styles, text styles, effect styles
```

### GET_ASSETS

Retrieve image asset URLs

```javascript
mcp_figma_get_assets({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign",
  "nodeId": "1234:5678",          // Optional
  "format": "png",                // jpg | png | svg | pdf
  "scale": 2                      // Optional
})
// Returns: image download URLs
```

### GET_VARIABLES

Retrieve design variables

```javascript
mcp_figma_get_variables({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign"
})
// Returns: variable collections, color/number/string variables
```

### IDENTIFY_COMPONENTS

Identify UI components

```javascript
mcp_figma_identify_components({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign",
  "nodeId": "1234:5678"           // Optional
})
// Returns: component type classification such as charts, tables, forms, etc.
```

### DETECT_VARIANTS

Detect component variants

```javascript
mcp_figma_detect_variants({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign"
})
// Returns: variant sets, classification by properties
```

### DETECT_RESPONSIVE

Detect responsive design

```javascript
mcp_figma_detect_responsive({
  "figmaUrl": "https://www.figma.com/file/abc123/MyDesign"
})
// Returns: list of responsive component variations
```

---

## Write Tools

> You must call `SWITCH_TO_WRITE_MODE` first before using any write tools.

### SWITCH_TO_WRITE_MODE

Enable write mode (Figma plugin connection)

```javascript
mcp_figma_switch_to_write_mode({
  "prompt": "Start design creation"    // Optional
})
```

### CREATE_FRAME

Create a frame

```javascript
mcp_figma_create_frame({
  "parentNodeId": "0:1",          // Parent node ID
  "name": "Login Screen",
  "x": 0,
  "y": 0,
  "width": 1440,
  "height": 900
})
// Returns: { nodeId: "new node ID" }
```

### CREATE_SHAPE

Create a shape (rectangle, ellipse, polygon)

```javascript
// Rectangle
mcp_figma_create_shape({
  "parentNodeId": "1234:5678",
  "type": "RECTANGLE",            // RECTANGLE | ELLIPSE | POLYGON
  "name": "Card Background",
  "x": 0,
  "y": 0,
  "width": 320,
  "height": 200,
  "fill": {                       // Optional
    "type": "SOLID",
    "color": { "r": 1, "g": 1, "b": 1 }
  },
  "cornerRadius": 12              // Optional
})

// Ellipse
mcp_figma_create_shape({
  "parentNodeId": "1234:5678",
  "type": "ELLIPSE",
  "name": "Avatar",
  "x": 16,
  "y": 16,
  "width": 48,
  "height": 48,
  "fill": {
    "type": "SOLID",
    "color": { "r": 0.9, "g": 0.9, "b": 0.9 }
  }
})

// Polygon
mcp_figma_create_shape({
  "parentNodeId": "1234:5678",
  "type": "POLYGON",
  "name": "Triangle",
  "x": 0,
  "y": 0,
  "width": 100,
  "height": 100,
  "points": 3                     // Number of vertices
})
```

### CREATE_TEXT

Create text

```javascript
mcp_figma_create_text({
  "parentNodeId": "1234:5678",
  "name": "Heading",
  "x": 24,
  "y": 24,
  "width": 280,
  "height": 40,
  "characters": "Login",
  "style": {                      // Optional
    "fontFamily": "Inter",
    "fontSize": 24,
    "fontWeight": 600,
    "fill": {
      "type": "SOLID",
      "color": { "r": 0.1, "g": 0.1, "b": 0.1 }
    },
    "textAlign": "LEFT"           // LEFT | CENTER | RIGHT
  }
})
```

### CREATE_COMPONENT

Create a component

```javascript
mcp_figma_create_component({
  "parentNodeId": "0:1",
  "name": "Button/Primary",
  "x": 0,
  "y": 0,
  "width": 120,
  "height": 40,
  "childrenData": [               // Optional: define child elements
    {
      "type": "RECTANGLE",
      "name": "Background",
      "x": 0,
      "y": 0,
      "width": 120,
      "height": 40,
      "fill": { "type": "SOLID", "color": { "r": 0.231, "g": 0.510, "b": 0.965 } },
      "cornerRadius": 8
    },
    {
      "type": "TEXT",
      "name": "Label",
      "x": 0,
      "y": 10,
      "width": 120,
      "height": 20,
      "characters": "Button",
      "style": {
        "fontFamily": "Inter",
        "fontSize": 14,
        "fontWeight": 500,
        "fill": { "type": "SOLID", "color": { "r": 1, "g": 1, "b": 1 } },
        "textAlign": "CENTER"
      }
    }
  ]
})
// Returns: { nodeId: "...", componentKey: "..." }
```

### CREATE_COMPONENT_INSTANCE

Create a component instance

```javascript
mcp_figma_create_component_instance({
  "parentNodeId": "1234:5678",
  "componentKey": "abc123...",    // Component key
  "name": "Submit Button",
  "x": 100,
  "y": 200,
  "scaleX": 1,                    // Optional
  "scaleY": 1                     // Optional
})
```

### UPDATE_NODE

Modify node properties

```javascript
mcp_figma_update_node({
  "nodeId": "1234:5678",
  "properties": {
    "name": "Updated Name",
    "x": 100,
    "y": 200,
    "width": 300,
    "height": 150,
    "visible": true,
    "opacity": 0.9,
    "rotation": 45,
    "locked": false
  }
})
```

### DELETE_NODE

Delete a node

```javascript
mcp_figma_delete_node({
  "nodeId": "1234:5678"
})
```

### SET_FILL

Set fill

```javascript
// Solid color
mcp_figma_set_fill({
  "nodeId": "1234:5678",
  "fill": {
    "type": "SOLID",
    "color": { "r": 0.231, "g": 0.510, "b": 0.965 },
    "opacity": 1
  }
})

// Gradient
mcp_figma_set_fill({
  "nodeId": "1234:5678",
  "fill": {
    "type": "GRADIENT_LINEAR",
    "gradientStops": [
      { "position": 0, "color": { "r": 0.2, "g": 0.4, "b": 0.9, "a": 1 } },
      { "position": 1, "color": { "r": 0.4, "g": 0.6, "b": 1, "a": 1 } }
    ]
  }
})
```

### SET_STROKE

Set stroke

```javascript
mcp_figma_set_stroke({
  "nodeId": "1234:5678",
  "stroke": {
    "type": "SOLID",
    "color": { "r": 0.8, "g": 0.8, "b": 0.8 }
  },
  "strokeWeight": 1               // Optional
})
```

### SET_EFFECTS

Set effects (shadows, blurs)

```javascript
mcp_figma_set_effects({
  "nodeId": "1234:5678",
  "effects": [
    {
      "type": "DROP_SHADOW",
      "color": { "r": 0, "g": 0, "b": 0, "a": 0.1 },
      "offset": { "x": 0, "y": 4 },
      "radius": 8,
      "spread": 0,
      "visible": true
    },
    {
      "type": "LAYER_BLUR",
      "radius": 4,
      "visible": true
    }
  ]
})
```

### SMART_CREATE_ELEMENT

Smart element creation (leveraging existing components)

```javascript
mcp_figma_smart_create_element({
  "parentNodeId": "1234:5678",
  "type": "button",               // button | input | card | header, etc.
  "name": "Primary Button",
  "x": 0,
  "y": 0,
  "width": 120,
  "height": 40,
  "properties": {                 // Optional: element-specific properties
    "variant": "primary",
    "label": "Submit"
  }
})
// AI selects a suitable component from the existing component library and creates it
```

### LIST_AVAILABLE_COMPONENTS

List available components

```javascript
mcp_figma_list_available_components({})
// Returns: component list classified by type
```

---

## Color Conversion Utilities

### HEX → Figma RGB

```javascript
function hexToFigmaRgb(hex) {
  const r = parseInt(hex.slice(1, 3), 16) / 255;
  const g = parseInt(hex.slice(3, 5), 16) / 255;
  const b = parseInt(hex.slice(5, 7), 16) / 255;
  return { r, g, b };
}

// Example
hexToFigmaRgb("#3B82F6")  // { r: 0.231, g: 0.510, b: 0.965 }
hexToFigmaRgb("#FFFFFF")  // { r: 1, g: 1, b: 1 }
hexToFigmaRgb("#000000")  // { r: 0, g: 0, b: 0 }
```

### Figma RGB → HEX

```javascript
function figmaRgbToHex({ r, g, b }) {
  const toHex = (n) => Math.round(n * 255).toString(16).padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

// Example
figmaRgbToHex({ r: 0.231, g: 0.510, b: 0.965 })  // "#3b82f6"
```

---

## Common Patterns

### 1. Creating a Basic Screen Frame

```javascript
// 1. Enable write mode
await mcp_figma_switch_to_write_mode({});

// 2. Create main frame
const frame = await mcp_figma_create_frame({
  parentNodeId: "0:1",
  name: "Login Screen",
  x: 0, y: 0,
  width: 1440, height: 900
});

// 3. Set background color
await mcp_figma_set_fill({
  nodeId: frame.nodeId,
  fill: { type: "SOLID", color: { r: 0.98, g: 0.98, b: 0.98 } }
});
```

### 2. Creating a Card Component

```javascript
// 1. Create card frame
const card = await mcp_figma_create_frame({
  parentNodeId: "1234:5678",
  name: "Card",
  x: 100, y: 100,
  width: 320, height: 200
});

// 2. Apply background and shadow
await mcp_figma_set_fill({
  nodeId: card.nodeId,
  fill: { type: "SOLID", color: { r: 1, g: 1, b: 1 } }
});

await mcp_figma_set_effects({
  nodeId: card.nodeId,
  effects: [{
    type: "DROP_SHADOW",
    color: { r: 0, g: 0, b: 0, a: 0.08 },
    offset: { x: 0, y: 2 },
    radius: 8
  }]
});

// 3. Convert to component
const component = await mcp_figma_create_component({
  parentNodeId: "0:1",
  name: "Card",
  x: 0, y: 0,
  width: 320, height: 200
});
```

### 3. Creating a Button Component

```javascript
const button = await mcp_figma_create_component({
  parentNodeId: "0:1",
  name: "Button/Primary",
  x: 0, y: 0,
  width: 120, height: 40,
  childrenData: [
    {
      type: "RECTANGLE",
      name: "Background",
      x: 0, y: 0,
      width: 120, height: 40,
      fill: { type: "SOLID", color: { r: 0.231, g: 0.510, b: 0.965 } },
      cornerRadius: 8
    },
    {
      type: "TEXT",
      name: "Label",
      x: 0, y: 10,
      width: 120, height: 20,
      characters: "Button",
      style: {
        fontFamily: "Inter",
        fontSize: 14,
        fontWeight: 500,
        fill: { type: "SOLID", color: { r: 1, g: 1, b: 1 } },
        textAlign: "CENTER"
      }
    }
  ]
});
```

### 4. Extracting and Applying Design System Styles

```javascript
// 1. Extract existing styles
const styles = await mcp_figma_extract_styles({
  figmaUrl: "https://www.figma.com/file/abc123/DesignSystem"
});

// 2. Create new elements using extracted colors
const primaryColor = styles.colors.find(c => c.name === "Primary/500");

await mcp_figma_set_fill({
  nodeId: "1234:5678",
  fill: {
    type: "SOLID",
    color: primaryColor.value
  }
});
```
