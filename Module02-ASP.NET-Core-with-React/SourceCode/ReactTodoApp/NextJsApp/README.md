# Next.js Todo App - Server-Side Rendering (SSR) Demo

This is a **Server-Side Rendered** version of the Todo application built with Next.js to demonstrate the differences between SSR and CSR (Client-Side Rendering).

## 🎯 Purpose

This application serves as a **teaching tool** to demonstrate:

- **Server-Side Rendering (SSR)** with Next.js
- **Comparison with CSR** (React SPA version)
- **SEO benefits** of pre-rendered content
- **Performance differences** between SSR and CSR
- **Real-world implementation** of SSR with ASP.NET Core API

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ installed
- ASP.NET Core API running on port 5000
- npm or yarn package manager

### Installation

```bash
# Navigate to the Next.js app directory
cd NextJsApp

# Install dependencies
npm install

# Start the development server
npm run dev
```

The application will be available at: **http://localhost:3001**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Browser       │    │   Next.js SSR    │    │  ASP.NET Core   │
│                 │    │   (Port 3001)    │    │  API (Port 5000)│
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ 1. Request Page │───▶│ 2. Server renders│───▶│ 3. Fetch data   │
│ 4. Receive HTML │◀───│    complete HTML │◀───│    from API     │
│ 5. Hydrate JS   │    │ 3. Send full HTML│    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📊 SSR vs CSR Comparison

| Feature | SSR (This App) | CSR (React SPA) |
|---------|----------------|-----------------|
| **Port** | 3001 | 5173 |
| **Initial Load** | ⚡ Fast (pre-rendered) | 🐌 Slower (JS execution) |
| **SEO** | ✅ Excellent | ❌ Poor (empty HTML) |
| **View Source** | 📄 Complete HTML | 📄 Empty div |
| **No JavaScript** | ✅ Content visible | ❌ Blank page |
| **Server Load** | 📈 Higher | 📉 Lower |

## 🔧 Key Features

### Server-Side Rendering
- **getServerSideProps**: Data fetched on server before page render
- **Pre-rendered HTML**: Complete content sent to browser
- **SEO Optimized**: Search engines see full content
- **Fast Initial Paint**: Content visible immediately

### Development Features
- **Hot Reload**: Instant updates during development
- **TypeScript**: Full type safety
- **API Proxy**: Seamless communication with ASP.NET Core
- **Error Handling**: Graceful fallbacks for API failures

## 📁 Project Structure

```
NextJsApp/
├── components/          # Reusable React components
│   ├── Layout.tsx      # Main layout with navigation
│   ├── TodoItem.tsx    # Individual todo item
│   └── TodoForm.tsx    # Add new todo form
├── lib/                # Utility libraries
│   └── api.ts          # API client for ASP.NET Core
├── pages/              # Next.js pages (file-based routing)
│   ├── _app.tsx        # App wrapper
│   ├── index.tsx       # Home page (SSR)
│   ├── stats.tsx       # Statistics page (SSR)
│   └── about.tsx       # About SSR explanation
├── types/              # TypeScript type definitions
│   └── todo.ts         # Todo-related types
├── next.config.js      # Next.js configuration
├── package.json        # Dependencies and scripts
└── tsconfig.json       # TypeScript configuration
```

## 🎓 Teaching Points

### 1. Server-Side Rendering Demonstration

**View Page Source** to see the difference:
- **SSR (this app)**: Complete HTML with todo data
- **CSR (React app)**: Empty `<div id="root"></div>`

### 2. Performance Comparison

**Network Throttling** (Chrome DevTools → Network → Slow 3G):
- **SSR**: Content appears immediately
- **CSR**: Loading delay while JavaScript downloads

### 3. SEO Benefits

**Search Engine Perspective**:
- **SSR**: Crawlers see complete content
- **CSR**: Crawlers see empty page

### 4. JavaScript Disabled Test

**Chrome DevTools → Settings → Disable JavaScript**:
- **SSR**: Content still visible (non-interactive)
- **CSR**: Completely blank page

## 🔗 API Integration

The Next.js app communicates with the same ASP.NET Core API as the React SPA:

```typescript
// Server-side API calls (getServerSideProps)
const todos = await todoApi.getAll(); // Runs on server

// Client-side API calls (after hydration)
const newTodo = await todoApi.create(todoData); // Runs in browser
```

### API Configuration

- **Development**: Proxy configured in `next.config.js`
- **Server-side**: Direct API calls to `http://localhost:5000`
- **Client-side**: Proxied through Next.js dev server

## 🚀 Deployment Considerations

### Development
```bash
npm run dev    # Development server with hot reload
```

### Production
```bash
npm run build  # Build optimized production bundle
npm start      # Start production server
```

### Environment Variables
```bash
API_BASE_URL=http://localhost:5000  # ASP.NET Core API URL
```

## 🎯 Learning Objectives

After exploring this SSR demo, students should understand:

1. **How SSR works** - Server renders React components to HTML
2. **When to use SSR** - SEO, performance, accessibility requirements
3. **SSR trade-offs** - Server load vs client performance
4. **Implementation differences** - getServerSideProps vs useEffect
5. **Real-world applications** - E-commerce, marketing sites, blogs

## 🔄 Comparison Workflow

1. **Start both applications**:
   - SSR: `http://localhost:3001` (this app)
   - CSR: `http://localhost:5173` (React SPA)

2. **Compare loading behavior**:
   - Throttle network to Slow 3G
   - Refresh both applications
   - Observe initial content appearance

3. **Examine source code**:
   - Right-click → View Page Source
   - Compare HTML content between versions

4. **Test without JavaScript**:
   - Disable JavaScript in DevTools
   - Refresh both applications
   - Note content availability

## 🛠️ Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Ensure ASP.NET Core API is running on port 5000
   - Check CORS configuration includes port 3001

2. **Port Already in Use**
   - Change port in package.json: `"dev": "next dev -p 3002"`
   - Update CORS configuration in ASP.NET Core

3. **Build Errors**
   - Run `npm install` to ensure dependencies are installed
   - Check TypeScript errors: `npm run lint`

## 📚 Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Server-Side Rendering Guide](https://nextjs.org/docs/basic-features/pages#server-side-rendering)
- [getServerSideProps API](https://nextjs.org/docs/basic-features/data-fetching/get-server-side-props)
- [React Hydration](https://react.dev/reference/react-dom/client/hydrateRoot)

---

**Happy Learning! 🎓**

This SSR demo provides hands-on experience with server-side rendering concepts and practical comparison with client-side rendering approaches.
