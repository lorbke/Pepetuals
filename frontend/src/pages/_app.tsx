// import '@/styles/theme.css';
import '@/styles/local.bootstrap.min.css';
import '@/styles/globals.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import '@near-wallet-selector/modal-ui/styles.css';
import 'react-bootstrap-typeahead/css/Typeahead.css';
import 'react-bootstrap-typeahead/css/Typeahead.bs5.css';

import '@/data/web3';

import type { AppProps } from 'next/app';
import dynamic from 'next/dynamic';
import Head from 'next/head';

import { Toaster } from '@/components/lib/Toast';
import { useBosLoaderInitializer } from '@/hooks/useBosLoaderInitializer';
import { useHashUrlBackwardsCompatibility } from '@/hooks/useHashUrlBackwardsCompatibility';
import type { NextPageWithLayout } from '@/utils/types';

import {NextUIProvider} from '@nextui-org/react'
import {ThemeProvider as NextThemesProvider} from "next-themes";

const VmInitializer = dynamic(() => import('../components/vm/VmInitializer'), {
  ssr: false,
});

type AppPropsWithLayout = AppProps & {
  Component: NextPageWithLayout;
};

export default function App({ Component, pageProps }: AppPropsWithLayout) {
  useBosLoaderInitializer();
  useHashUrlBackwardsCompatibility();

  const getLayout = Component.getLayout ?? ((page) => page);

  return (
    <>
      <Head>
        <link rel="icon" href="favicon.ico" />
      </Head>

      <VmInitializer />

      <NextUIProvider>
        <NextThemesProvider attribute="class" defaultTheme="light">
          {getLayout(<Component {...pageProps} />)}
        </NextThemesProvider>
      </NextUIProvider>

      <Toaster />
    </>
  );
}
