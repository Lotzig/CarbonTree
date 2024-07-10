'use client';
import NotConnected from "@/components/shared/NotConnected";
import Admin from "@/components/shared/Admin";
import Customer from "@/components/shared/Customer";
import { useAccount } from "wagmi";

export default function Home() {

  const { isConnected } = useAccount()

  return (
     <>
      {isConnected ? (
        <div>
          <div>Admin</div>
          <div>Customer</div>
        </div>
      ) : (
        <NotConnected />
      )}
    </>
  );
}
