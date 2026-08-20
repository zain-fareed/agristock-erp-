import { Route, Routes } from 'react-router-dom'
import { ProtectedRoute } from '@/components/protected-route'
import { NotFoundPage } from '@/pages/not-found'
import { ProtectedHomePage } from '@/pages/protected-home'
import { SignInPage } from '@/pages/sign-in'
import { SignUpPage } from '@/pages/sign-up'

function App() {
  return (
    <Routes>
      <Route path="/sign-in" element={<SignInPage />} />
      <Route path="/sign-up" element={<SignUpPage />} />
      <Route element={<ProtectedRoute />}>
        <Route path="/" element={<ProtectedHomePage />} />
      </Route>
      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  )
}

export default App
