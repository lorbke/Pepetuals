import {Navbar, NavbarBrand, NavbarContent, NavbarItem, Link, NavbarMenuToggle} from "@nextui-org/react";
import { usePathname } from 'next/navigation';
import { useState } from "react";

export const MainNavbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const pathname = usePathname();

  return (
    <Navbar isMenuOpen={isMenuOpen} onMenuOpenChange={(open) => setIsMenuOpen(open)}>
      <NavbarContent className="sm:hidden" justify="start">
        <NavbarMenuToggle />
      </NavbarContent>

      <NavbarContent className="sm:hidden pr-3" justify="center">
        <NavbarBrand>
          <p className="font-bold text-inherit">TEST</p>
        </NavbarBrand>
      </NavbarContent>

      <NavbarContent className="hidden sm:flex gap-4" justify="center">
        <NavbarBrand>
          <p className="font-bold text-inherit">TEST</p>
        </NavbarBrand>
        <NavbarItem isActive={pathname == ""}>
          <Link color="foreground" href="#">
            Features
          </Link>
        </NavbarItem>
        <NavbarItem isActive={pathname == ""}>
          <Link href="#" aria-current="page" color="warning">
            Customers
          </Link>
        </NavbarItem>
        <NavbarItem isActive={pathname == ""}>
          <Link color="foreground" href="#">
            Integrations
          </Link>
        </NavbarItem>
      </NavbarContent>

      <NavbarContent justify="end">
        <NavbarItem>
          <span>hiii</span>
        </NavbarItem>
      </NavbarContent>
    </Navbar>
  );
}

