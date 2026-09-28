import { useLocation, useNavigate, useSearchParams } from "react-router-dom";
import { OrderLookupModal } from "@/components/OrderLookupModal";
import { paths } from "@/lib/paths";

export function LookupPage() {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const location = useLocation();
  const from = (location.state as { from?: string } | null)?.from;

  return (
    <OrderLookupModal
      variant="page"
      initialCode={params.get("ma") || ""}
      onClose={() => navigate(from || paths.home)}
    />
  );
}
