#!/bin/bash

echo "Running template builder shell script."

echo "Please enter the git clone link"
read gitRepoLink
gitRepo=$(basename -s .git "${gitRepoLink:27}")
echo "Cloning $gitRepo repo using $gitRepoLink. Please wait."
git clone "$gitRepoLink"

echo "Configuring frontend."
cd $gitRepo
npm create vite@latest "frontend" -- --template react-ts

cd frontend
npm install

npm install react-router-dom
npm install tailwindcss @tailwindcss/vite
npm install @tanstack/react-query

cat <<EOF > index.html
<!doctype html>
<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<link rel="icon" type="image/svg+xml" href="/vite.svg" />
		<title>$gitRepo</title>
	</head>
	<body>
		<div id="root"></div>
		<script type="module" src="/src/main.tsx"></script>
	</body>
</html>
EOF

cat <<EOF > src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App.tsx'
import './index.css'
import { QueryClientProvider, QueryClient } from '@tanstack/react-query'

const queryClient = new QueryClient()

ReactDOM.createRoot(document.getElementById('root')!).render(
	<React.StrictMode>
		<BrowserRouter>
			<QueryClientProvider client={queryClient}>
				<App />
			</QueryClientProvider>
		</BrowserRouter>
	</React.StrictMode>,
)
EOF

cat <<EOF > src/index.css
@import "tailwindcss";

:root {
	font-family: system-ui, Avenir, Helvetica, Arial, sans-serif;
	line-height: 1.5;
	font-weight: 400;

	color-scheme: light dark;
	color: rgba(255, 255, 255, 0.87);
	background-color: #18181B;

	font-synthesis: none;
	text-rendering: optimizeLegibility;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
}

body {
	background-color: var(--background-color);
}
EOF

cat <<EOF > src/App.tsx
import { Routes, Route, Outlet } from 'react-router-dom'
import HomePage from './pages/HomePage.tsx'
import Header from './components/Header.tsx'
import Footer from './components/Footer.tsx'

export default function App() {
  // defining default layout
  const Layout = () => {
    return (
      <div>
        <Header/>
        <Outlet/>
        <Footer/>
      </div>
    )
  }

  return (
    <div>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route path="/" element={<HomePage />} />
        </Route>
      </Routes>
    </div>
  );
}
EOF

mkdir -p src/components
cat <<'EOF' > src/components/Header.tsx
export default function Header(){
	const scrollToSpot = (pixels: number): void => {
		window.scrollTo({ top: pixels, behavior: 'smooth'});
	}

	const openJobsPage = () => {
		window.location.href='/Jobs'
	}

	return (
		<div className={`flex flex-row w-full justify-between h-12 px-2`}>

			{/* UI Change button */}
			<div className="flex w-30 justify-center">
				<button className={`transition-all cursor-pointer font-medium duration-200 self-center px-2 py-1 bg-purple-600 rounded-lg active:bg-purple-900`}>Button</button>
			</div>

			{/* Middle */}
			<div className="flex flex-row items-center text-white">
				<div className="w-18 text-center"><a onClick={() => scrollToSpot(700)} className={`inline-block mx-2 cursor-pointer font-bold text-lg transition-all  duration-300 hover:scale-125 `}>Games</a></div>
				<div className="w-18 text-center"><a onClick={() => scrollToSpot(950)} className={`inline-block mx-2 cursor-pointer font-bold text-lg transition-all duration-300 hover:scale-125 `}>Team</a></div>
				<div className="w-18 text-center"><a onClick={openJobsPage} className={`inline-block mx-2 cursor-pointer font-bold text-lg transition-all duration-300 hover:scale-125`}>Jobs</a></div>
			</div>

			{/* Icons */}
			<div className="flex justify-center w-30">
				<a className="self-center cursor-pointer" href="mailto:tbspgames@gmail.com"><img src="" className={`h-9 object-contain transition-all duration-300 hover:scale-125 mr-2`} ></img>Hi</a>
				<a className="self-center cursor-pointer" href="https://tbspgames.itch.io/"><img src="" className={`h-6 object-contain transition-all duration-300 hover:scale-125 `} ></img>Hi</a>
			</div>
		</div>
	)
}
EOF

cat <<EOF > src/components/Footer.tsx
export default function Footer(){

	return (
		<div className="flex w-full justify-center bg-purple-950 py-2">
			<p className="text-xs">Copyright 2025 tbsp games</p>
		</div>
	)
}
EOF

mkdir -p src/pages
cat <<'EOF' > src/pages/HomePage.tsx
export default function HomePage(){
	return (
		<div className={`flex flex-col items-center min-h-screen w-200 mx-auto py-20 bg-zinc-900`}>

			{/* About */}
			<div className={`w-150 p-3 mx-20 my-8`}>
				<h1 className={`text-3xl`}>About</h1>
				<div className={`h-1 my-3`}></div>
				<p>
					Founded in 2025 in Toronto, Canada, tbsp games is a team of diverse, 
					international creatives that have a love and passion for making games that are not too big, and not too small.
				</p>
			</div>
		</div>
	)
}
EOF


cd ..
mkdir -p backend
cd backend
touch main.go
go mod init "backend"

cat <<EOF > main.go
package main

import "fmt"

func main() {
	fmt.Println("Hello, Go project!")
}
EOF

npm install -D @vitejs/plugin-react-swc

cd ../frontend
cat <<EOF > vite.config.ts
import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react-swc'

export default defineConfig({
	plugins: [
    	react(),
    	tailwindcss(),
	,
})
EOF
