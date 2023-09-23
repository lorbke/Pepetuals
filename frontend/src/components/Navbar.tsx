import {Navbar, NavbarBrand, NavbarContent, NavbarItem, NavbarMenuToggle, NavbarMenu, NavbarMenuItem, Link} from "@nextui-org/react";
import { usePathname } from 'next/navigation';
import { useState } from "react";
import NextLink from "next/link";

export const MainNavbar = () => {
	const [isMenuOpen, setIsMenuOpen] = useState(false);
	const pathname = usePathname();

	const navbarName = "TEST";
	const navbarItems = [
		{
		name: "Long/Short",
		href: "/",
		},
		{
		name: "Customers",
		href: "#",
		},
		{
		name: "Integrations",
		href: "#",
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
					<p className="font-bold text-inherit">{navbarName}</p>
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
					<span>hiii</span>
				</NavbarItem>
			</NavbarContent>

			<NavbarMenu>
				{navbarItems.map((item, index) => (
					<NavbarMenuItem key={`${item.name}-${index}`}>
						<Link color={pathname == item.href ? "primary" : "foreground"} className="w-full" href={item.href} as={NextLink}>
							{item.name}
						</Link>
					</NavbarMenuItem>
				))}
			</NavbarMenu>
		</Navbar>
	);
}
