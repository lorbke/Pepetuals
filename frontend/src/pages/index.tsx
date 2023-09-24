import { useDefaultLayout } from '@/hooks/useLayout';
import type { NextPageWithLayout } from '@/utils/types';
import { ComponentWrapperPage } from '@/components/ComponentWrapperPage';

const HomePage: NextPageWithLayout = () => {
  return (<div className='w-full !py-3'>
    <ComponentWrapperPage src="paulg00.testnet/widget/LSC.Main"/>
  </div>);
};

HomePage.getLayout = useDefaultLayout;

export default HomePage;
