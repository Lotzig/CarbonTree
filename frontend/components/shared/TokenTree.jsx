import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"


const TokenTree = ({ tokenTree }) => {

  return (
    <>
    {tokenTree.key == 0 ? 
      (
        <Card className="p-4 mb-2">
            <div className="flex flex-none items-center text-center font-bold">
                <Badge className="bg-lime-500 font-bold"><span className="w-12 text-center">Key</span></Badge>
                <p className="mx-2">|</p> 
                <p className="w-20">Tree Id</p>
                <p className="mx-2">|</p> 
                <p className="w-52">Species</p>
                <p className="mx-2">|</p> 
                <p className="w-28">Price (ETH)</p>
                <p className="mx-2">|</p> 
                <p className="w-32">Planting Date</p>
                <p className="mx-2">|</p> 
                <p className="w-96">Tree Location</p>
                <p className="mx-2">|</p> 
                <p className="w-52">Tree Location Owner Name</p>
                <p className="mx-2">|</p> 
                <p className="w-96">Tree Location Owner Address</p>
            </div>
        </Card>
      ) :
      (
        <Card className="p-4 mb-2">
            <div className="flex flex-none items-center text-center">
                <Badge className="bg-lime-500 font-bold"><span className="w-12 text-center">{tokenTree.key.toString()}</span></Badge>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-20">{tokenTree.treeId.toString()}</p>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-52">{tokenTree.species}</p>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-28">{(Number(tokenTree.price) / Number(1E18)).toString()}</p>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-32">{tokenTree.plantingDate.toString()}</p>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-96">{tokenTree.location}</p>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-52">{tokenTree.locationOwnerName}</p>
                <p className="mx-2 font-bold">|</p> 
                <p className="w-96">{tokenTree.locationOwnerAddress}</p>
            </div>
        </Card>
      )
    }
    </>
  )
}

export default TokenTree
