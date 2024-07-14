import { ExclamationTriangleIcon } from "@radix-ui/react-icons"
 
import {
  Alert,
  AlertDescription,
  AlertTitle,
} from "@/components/ui/alert"

import Image from 'next/image'
import Accueil1 from '@/images/Accueil1.png'
import Accueil2 from '@/images/Accueil2.png'


const NotConnected = () => {
  return (
    <>
      <div className="flex flex-col space-y-4 items-center">
        <Image
          src={Accueil1}
          alt="CARBONTREE"
          //width={500} 
          //height={500}
        />

        <Image
          src={Accueil2}
          alt="CARBONTREE"
          //width={1000} automatically provided
          // height={500} automatically provided
        />
      
        <div className="bg-lime-600 text-2xl text-white p-5">Connect your wallet to purchase CARB-B !</div>

      </div>

    </>
  )
}

export default NotConnected
