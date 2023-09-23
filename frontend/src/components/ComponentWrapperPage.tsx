import { VmComponent } from '@/components/vm/VmComponent';
import styled from 'styled-components';
import { MetaTags } from './MetaTags';

type Props = {
  componentProps?: Record<string, unknown>;
  src: string;
  className?: string;
  meta?: {
    title: string;
    description: string;
  };
};

export function ComponentWrapperPage(props: Props) {
  return (
    <>
      {props.meta && <MetaTags {...props.meta} />}

      <div className={props.className}>
        <VmComponent src={props.src} props={props.componentProps} />
      </div>
    </>
  );
}
