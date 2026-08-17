import { Link } from 'react-router-dom'

export const NotFoundPage = () => {
  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col justify-center gap-4 px-6 text-center">
      <h1 className="text-2xl font-semibold">Page not found</h1>
      <Link className="text-primary" to="/">
        Go back home
      </Link>
    </main>
  )
}
