import { ConnectButton } from "@rainbow-me/rainbowkit";

const Header = () => {
    return (
        <nav className="navbar">
            <div className="text-5xl">CARBONTREE</div>
            <div>
                <ConnectButton />
            </div>
        </nav>
    )
}

export default Header;
