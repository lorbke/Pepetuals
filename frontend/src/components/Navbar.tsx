import {Navbar, NavbarBrand, NavbarContent, NavbarItem, NavbarMenuToggle, NavbarMenu, NavbarMenuItem, Link} from "@nextui-org/react";
import { useWallets } from '@web3-onboard/react';
import { usePathname } from 'next/navigation';
import { useState } from "react";
import NextLink from "next/link";
import Image from "next/image";

import icon from '@/assets/images/logo.svg';

export const MainNavbar = () => {
	const [isMenuOpen, setIsMenuOpen] = useState(false);
	const connectedWallets = useWallets();
	const pathname = usePathname();

	const accountAddress = connectedWallets[0]?.accounts[0].address ?? "";

	const navbarItems = [
		{
			name: "Long/Short",
			href: "/",
		},
		{
			name: "Positions",
			href: "/positions",
		}
	];

	return (
		<Navbar className="z-10" isMenuOpen={isMenuOpen} onMenuOpenChange={(open) => setIsMenuOpen(open)}>
			<NavbarContent>
				<NavbarMenuToggle
					aria-label={isMenuOpen ? "Close menu" : "Open menu"}
					className="sm:hidden"
				/>
				<NavbarBrand>
					<Image src={icon} alt="logo" width={50} height={50}/>
					<p className="font-bold text-inherit text-xl"><span className="text-green-700">Pepe</span>tuals</p>
				</NavbarBrand>
			</NavbarContent>

			<NavbarContent className="hidden sm:flex gap-4" justify="center">
				{navbarItems.map((item, index) => (
					<NavbarItem isActive={pathname == item.href} key={`${item.name}-${index}`}>
						<Link color={pathname == item.href ? "primary" : "foreground"} href={item.href} as={NextLink}>
							{item.name}
						</Link>
					</NavbarItem>
				))}
			</NavbarContent>

			<NavbarContent justify="end">
				<NavbarItem>
					{accountAddress != "" && <span className="font-bold">{`${accountAddress.slice(0, 6)}...${accountAddress.slice(accountAddress.length - 4, accountAddress.length)}`}</span>}
					{accountAddress == "" && <span>Please Connect Wallet</span>}
				</NavbarItem>
			</NavbarContent>

			<NavbarMenu>
				{navbarItems.map((item, index) => (
					<NavbarMenuItem key={`${item.name}-${index}`}>
						<Link color={pathname == item.href ? "primary" : "foreground"} className="w-full text-xl" href={item.href} as={NextLink} onClick={() => setIsMenuOpen(false)}>
							{item.name}
						</Link>
					</NavbarMenuItem>
				))}
			</NavbarMenu>
		</Navbar>
	);
}
