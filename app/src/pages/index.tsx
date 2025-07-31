import { NextPage } from 'next'
import Head from 'next/head'
import styles from '@/styles/Home.module.css'

const Home: NextPage = () => {
  return (
    <div className={styles.container}>
      <Head>
        <title>DevOps Project - Hola Mundo</title>
        <meta name="description" content="Proyecto final DevOps - Aplicación Next.js" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>
          ¡Hola Mundo! 🚀
        </h1>

        <p className={styles.description}>
          Proyecto Final DevOps - Next.js + TypeScript
        </p>

        <div className={styles.grid}>
          <div className={styles.card}>
            <h2>Pipeline CI/CD &rarr;</h2>
            <p>GitHub Actions + SonarQube + VM Deployment</p>
          </div>

          <div className={styles.card}>
            <h2>Technologies &rarr;</h2>
            <p>Next.js, React, TypeScript, Docker</p>
          </div>

          <div className={styles.card}>
            <h2>Infrastructure &rarr;</h2>
            <p>VMware Workstation + Ubuntu + Docker</p>
          </div>

          <div className={styles.card}>
            <h2>Quality &rarr;</h2>
            <p>ESLint, Jest, SonarQube Analysis</p>
          </div>
        </div>
      </main>

      <footer className={styles.footer}>
        <a
          href="https://github.com"
          target="_blank"
          rel="noopener noreferrer"
        >
          Powered by DevOps Pipeline
        </a>
      </footer>
    </div>
  )
}

export default Home 