# Frontend Component Review Checklist

## Component Design

### Separation Principles
- [ ] Are Presentational and Container components properly separated?
- [ ] Does any single component carry too many responsibilities? (Consider splitting if over 200 lines)
- [ ] Is reusable UI logic extracted into shared components?
- [ ] Is business logic mixed into UI components?

### Props Design
- [ ] Are Props interfaces clearly defined with proper types?
- [ ] Are too many props being passed unnecessarily? (Prop Drilling)
- [ ] Is the composition pattern using children being utilized appropriately?
- [ ] Do optional props have appropriate default values?

### State Management
- [ ] Is server state managed with the project's data-fetching library (e.g., React Query, Vue Query, SWR)?
- [ ] Is client state managed with the project's state management tool (e.g., Zustand, Pinia)?
- [ ] Is state managed at the minimum necessary scope? (No unnecessary global state)
- [ ] Is derived state being managed as separate state unnecessarily?

```tsx
// 🔴 Managing derived state separately
const [items, setItems] = useState([]);
const [filteredItems, setFilteredItems] = useState([]); // Can be derived from items

// ✅ Derive with useMemo
const [items, setItems] = useState([]);
const filteredItems = useMemo(
  () => items.filter(item => item.active),
  [items]
);
```

## React Hook Patterns

### useEffect Checklist
- [ ] Is the dependency array accurate? (No missing or unnecessary items?)
- [ ] Is a cleanup function written where needed? (Subscriptions, timers, AbortController)
- [ ] Does the useEffect set state that causes unnecessary re-renders?
- [ ] Is React Query used for data fetching instead of useEffect?

```tsx
// 🔴 Fetching data with useEffect
useEffect(() => {
  fetch('/api/users').then(res => res.json()).then(setUsers);
}, []);

// ✅ Using React Query
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => fetchUsers(),
});
```

### Custom Hook Checklist
- [ ] Is repeated logic extracted into custom Hooks?
- [ ] Does the Hook name start with `use`?
- [ ] Does the Hook have a single responsibility?
- [ ] Are other Hooks not being called conditionally inside the Hook?

## Form Handling

### React Hook Form + Zod
- [ ] Is Zod schema used for form validation?
- [ ] Are error messages user-friendly?
- [ ] Is duplicate submission prevented during submission? (isSubmitting)
- [ ] Are server errors displayed appropriately in the form?

## API Integration

### OpenAPI Generated Client Checklist

> Adapt these checks to your project's API client generation tool (orval, openapi-generator-cli, etc.) and data-fetching library (React Query, Vue Query, SWR, etc.).

- [ ] Are generated types used instead of manually defined types?
- [ ] Are generated API hooks/clients used instead of manual API calls?
- [ ] Were auto-generated files not directly modified?
- [ ] Is custom logic handled in wrapper hooks/composables in the `hooks/` folder?
- [ ] Is cache invalidation properly handled after mutation success?

```tsx
// 🔴 Manual API call
const [users, setUsers] = useState([]);
useEffect(() => {
  axios.get('/api/users').then(res => setUsers(res.data));
}, []);

// ✅ Using generated hooks
const { data: users } = useGetUsers();
```

## Routing and Navigation

- [ ] Are authentication guards applied to routes that require login?
- [ ] Is there 404 handling for non-existent routes?
- [ ] Do deep links and back navigation work correctly?
- [ ] Is necessary data prefetched on route changes?

## Error Handling

- [ ] Is there user feedback for API errors? (Toasts, error messages)
- [ ] Are Error Boundaries placed appropriately?
- [ ] Is there a retry mechanism for network errors?
- [ ] Are loading, error, and empty states all handled?
