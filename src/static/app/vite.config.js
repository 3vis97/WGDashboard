import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import {proxy} from "./proxy.js";
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig(({mode}) => {
  

  if (mode === 'electron'){
    return {
      emptyOutDir: false,
      base: './',
      plugins: [
        vue(),
      ],
      resolve: {
        alias: {
          '@': fileURLToPath(new URL('./src', import.meta.url))
        }
      },
      server:{
        proxy: {
          '/api': proxy
        }
      },
      build: {
        outDir: 'electron',
        rollupOptions: {
          output: {
            entryFileNames: `assets/[name].js`,
            chunkFileNames: `assets/[name].js`,
            assetFileNames: `assets/[name].[ext]`
          }
        }
      }
    }
  }

  return {
    base: "/static/app/dist",
    plugins: [
      vue(),
    ],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      }
    },
    server:{
      proxy: {
        '/api': proxy
      },
      host: '0.0.0.0'
    },
    build: {
      outDir: 'dist',
      rollupOptions: {
        output: {
          entryFileNames: `assets/[name].js`,
          chunkFileNames: `assets/[name].js`,
          assetFileNames: `assets/[name].[ext]`
        }
      }
    }
  }
})
