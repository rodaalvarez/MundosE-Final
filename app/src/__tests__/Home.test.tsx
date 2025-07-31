import { render, screen } from '@testing-library/react'
import Home from '../pages/index'

describe('Home', () => {
  it('renders a heading', () => {
    render(<Home />)
    
    const heading = screen.getByRole('heading', {
      name: /¡Hola Mundo! 🚀/i,
    })
    
    expect(heading).toBeInTheDocument()
  })

  it('renders the description', () => {
    render(<Home />)
    
    const description = screen.getByText(/Proyecto Final DevOps - Next.js \+ TypeScript/i)
    
    expect(description).toBeInTheDocument()
  })

  it('renders all cards', () => {
    render(<Home />)
    
    const cards = screen.getAllByRole('heading', { level: 2 })
    
    expect(cards).toHaveLength(4)
    expect(cards[0]).toHaveTextContent('Pipeline CI/CD')
    expect(cards[1]).toHaveTextContent('Technologies')
    expect(cards[2]).toHaveTextContent('Infrastructure')
    expect(cards[3]).toHaveTextContent('Quality')
  })
}) 