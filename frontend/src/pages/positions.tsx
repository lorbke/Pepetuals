import { useDefaultLayout } from '@/hooks/useLayout';
import type { NextPageWithLayout } from '@/utils/types';
import { ComponentWrapperPage } from '@/components/ComponentWrapperPage';

const PositionsPage: NextPageWithLayout = () => {
  return (<div className='w-full !py-3'>
    <ComponentWrapperPage src="paulg00.testnet/widget/LSP.Main"/>
  </div>);
};

PositionsPage.getLayout = useDefaultLayout;

export default PositionsPage;
