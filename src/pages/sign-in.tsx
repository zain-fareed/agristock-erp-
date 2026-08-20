import { type FormEvent, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { signInWithEmail } from '@/lib/auth'

export const SignInPage = () => {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmitting(true)
    setError(null)

    const result = await signInWithEmail(email, password)
    setSubmitting(false)

    if (result.error) {
      setError(result.error.message)
      return
    }

    navigate('/')
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col justify-center gap-6 px-6">
      <header className="space-y-2 text-center">
        <h1 className="text-2xl font-semibold">AgriStock ERP</h1>
        <p className="text-sm text-muted-foreground">Sign in to continue</p>
      </header>
      <form className="space-y-4" onSubmit={handleSubmit}>
        <input
          className="w-full rounded-md border p-3"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          placeholder="Email"
          required
        />
        <input
          className="w-full rounded-md border p-3"
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Password"
          minLength={8}
          required
        />
        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        <button className="w-full rounded-md bg-primary p-3 text-sm font-medium text-primary-foreground" disabled={submitting} type="submit">
          {submitting ? 'Signing in...' : 'Sign in'}
        </button>
      </form>
      <p className="text-center text-sm text-muted-foreground">
        New user? <Link className="text-primary" to="/sign-up">Create account</Link>
      </p>
    </main>
  )
}
