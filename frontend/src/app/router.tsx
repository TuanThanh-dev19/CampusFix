import { createBrowserRouter, Navigate } from 'react-router'
import { LoginPage } from '../features/auth/pages/LoginPage'
import { DashboardPage } from '../features/dashboard/pages/DashboardPage'
import { TicketListPage } from '../features/tickets/pages/TicketListPage'
import { AppLayout } from '../layouts/AppLayout'
import { ProtectedRoute } from '../routes/ProtectedRoute'
import { RequireRole } from '../routes/RequireRole'
import { HomePage } from '../shared/components/HomePage'
import { PlaceholderPage } from '../shared/components/PlaceholderPage'

export const router = createBrowserRouter([
  {
    element: <AppLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'login', element: <LoginPage /> },
      {
        element: <ProtectedRoute />,
        children: [
          { path: 'dashboard', element: <DashboardPage /> },
          { path: 'tickets', element: <TicketListPage /> },
          {
            element: <RequireRole roles={['MANAGER', 'ADMIN']} />,
            children: [
              {
                path: 'assets',
                element: (
                  <PlaceholderPage
                    title="Equipment & assets"
                    description="Equipment types, individual assets, locations, and status history belong here."
                  />
                ),
              },
              {
                path: 'categories',
                element: (
                  <PlaceholderPage
                    title="Dynamic categories"
                    description="Build, validate, version, and publish incident forms here."
                  />
                ),
              },
            ],
          },
          {
            element: <RequireRole roles={['ADMIN']} />,
            children: [
              {
                path: 'administration',
                element: (
                  <PlaceholderPage
                    title="Administration"
                    description="Users, roles, permissions, and audit logs belong here."
                  />
                ),
              },
            ],
          },
        ],
      },
      {
        path: 'unauthorized',
        element: (
          <PlaceholderPage
            title="403 — Unauthorized"
            description="Your current role cannot access this page."
          />
        ),
      },
      { path: '*', element: <Navigate to="/" replace /> },
    ],
  },
])
