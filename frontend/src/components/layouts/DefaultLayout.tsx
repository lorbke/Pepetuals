import type { ReactNode } from 'react';

import { MainNavbar } from '@/components/Navbar';

interface Props {
  children: ReactNode;
}

export function DefaultLayout({ children }: Props) {
  return (
    <>
      <MainNavbar />
      {children}
    </>
  );
}
