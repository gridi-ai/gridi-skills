# Frontend Performance Review Checklist

## Rendering Optimization

### Preventing Unnecessary Re-renders
- [ ] Are new objects/arrays/functions not being created on every render and passed to children?
- [ ] Are `useMemo` and `useCallback` used only where appropriate? (No excessive memoization)
- [ ] Is the Context value not being re-created on every render?

```tsx
// 🔴 New object on every render
<Child config={{ theme: 'dark', size: 'lg' }} />

// ✅ Stabilize with useMemo (when child is memo'd)
const config = useMemo(() => ({ theme: 'dark', size: 'lg' }), []);
<Child config={config} />

// 🔴 New function on every render
<Button onClick={() => handleClick(id)} />

// ✅ useCallback (for repeated rendering such as list items)
const handleItemClick = useCallback((id: string) => {
  // ...
}, []);
```

### List Rendering
- [ ] Are lists with 1000+ items using virtualization?
- [ ] Are unique and stable values used for the key prop? (Avoid using index)
- [ ] Are list item components optimized with `React.memo` where necessary?

### Conditional Rendering
- [ ] Are hidden components not being unnecessarily mounted?
- [ ] Are heavy components code-split with `React.lazy`?

## Network Optimization

### Data Fetching
- [ ] Are there no unnecessary API calls? (Duplicate requests, unnecessary refetching)
- [ ] Is `staleTime` configured to prevent unnecessary refetching?
- [ ] Are pagination/infinite scroll applied where needed?
- [ ] Is Prefetch utilized to improve user experience?

```tsx
// 🔴 No staleTime set → refetches on every component mount
useQuery({ queryKey: ['config'], queryFn: fetchConfig });

// ✅ Appropriate staleTime setting
useQuery({
  queryKey: ['config'],
  queryFn: fetchConfig,
  staleTime: 5 * 60 * 1000, // Stays fresh for 5 minutes
});
```

### Image Optimization
- [ ] Is `next/image` used in Next.js projects?
- [ ] Are `width` and `height` attributes specified? (Prevents CLS)
- [ ] Are images outside the viewport using `loading="lazy"`?
- [ ] Are appropriate image formats (WebP, AVIF) being used?

### Bundle Size
- [ ] Are individual functions imported instead of entire libraries?
- [ ] Has the bundle size impact of newly added dependencies been checked?
- [ ] Is code splitting applied with dynamic imports (`React.lazy`)?

```tsx
// 🔴 Full import → increased bundle size
import _ from 'lodash';
import * as Icons from 'lucide-react';

// ✅ Individual import → tree-shaking possible
import { debounce } from 'lodash-es';
import { Search, Menu } from 'lucide-react';
```

## Memory Management

### Preventing Memory Leaks
- [ ] Are timers (setInterval, setTimeout) cleaned up on component unmount?
- [ ] Are event listeners removed in cleanup?
- [ ] Are incomplete API requests cancelled with AbortController?
- [ ] Are WebSocket/SSE connections closed in cleanup?

```tsx
// ✅ Cleanup pattern
useEffect(() => {
  const controller = new AbortController();
  fetchData({ signal: controller.signal });

  const timer = setInterval(tick, 1000);
  window.addEventListener('resize', handleResize);

  return () => {
    controller.abort();
    clearInterval(timer);
    window.removeEventListener('resize', handleResize);
  };
}, []);
```

## Web Vitals

### Core Web Vitals Check
- [ ] **LCP** (Largest Contentful Paint): Is main content rendered quickly?
- [ ] **CLS** (Cumulative Layout Shift): Is layout shift minimized?
- [ ] **INP** (Interaction to Next Paint): Are interaction responses fast?

### Preventing CLS
- [ ] Are dimensions pre-specified for images/videos?
- [ ] Is there no layout shift caused by font loading? (`font-display: swap`)
- [ ] Is space reserved in advance when dynamically inserting content?
