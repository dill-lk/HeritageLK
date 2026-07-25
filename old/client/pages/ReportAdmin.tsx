import { useState, useEffect } from "react";
import {
  ArrowLeft,
  Bell,
  AlertTriangle,
  CheckCircle,
  Clock,
  XCircle,
  Eye,
  Filter,
  RefreshCw,
} from "lucide-react";
import { Link } from "react-router-dom";
import BottomNav from "@/components/BottomNav";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";

interface DamageReport {
  id: string;
  location: string;
  damage_type: string;
  details: string;
  status: string;
  user_id: string;
  created_at: string;
}

const statusConfig: Record<
  string,
  { color: string; bg: string; icon: typeof CheckCircle; label: string }
> = {
  pending: {
    color: "text-[#F4A261]",
    bg: "bg-[#F4A261]/10 border-[#F4A261]/30",
    icon: Clock,
    label: "Pending",
  },
  reviewed: {
    color: "text-[#52B788]",
    bg: "bg-[#52B788]/10 border-[#52B788]/30",
    icon: Eye,
    label: "Reviewed",
  },
  resolved: {
    color: "text-[#A8DADC]",
    bg: "bg-[#A8DADC]/10 border-[#A8DADC]/30",
    icon: CheckCircle,
    label: "Resolved",
  },
  rejected: {
    color: "text-[#E76F51]",
    bg: "bg-[#E76F51]/10 border-[#E76F51]/30",
    icon: XCircle,
    label: "Rejected",
  },
};

export default function ReportAdmin() {
  const [reports, setReports] = useState<DamageReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState<string>("all");
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const { toast } = useToast();

  const fetchReports = async () => {
    setLoading(true);
    try {
      if (supabase) {
        let query = supabase
          .from("damage_reports")
          .select("*")
          .order("created_at", { ascending: false });

        if (filterStatus !== "all") {
          query = query.eq("status", filterStatus);
        }

        const { data, error } = await query;
        if (error) {
          console.log("Error fetching reports:", error);
          setReports([]);
        } else {
          setReports(data || []);
        }
      }
    } catch (err) {
      console.log("Failed to fetch reports:", err);
      setReports([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReports();
  }, [filterStatus]);

  const updateStatus = async (id: string, newStatus: string) => {
    setUpdatingId(id);
    try {
      if (supabase) {
        const { error } = await supabase
          .from("damage_reports")
          .update({ status: newStatus })
          .eq("id", id);

        if (error) {
          toast({
            variant: "destructive",
            title: "Failed to update",
            description: error.message,
          });
        } else {
          toast({
            title: "Status Updated",
            description: `Report marked as ${newStatus}`,
          });
          fetchReports();
        }
      }
    } catch (err: any) {
      toast({
        variant: "destructive",
        title: "Error",
        description: err.message,
      });
    } finally {
      setUpdatingId(null);
    }
  };

  const stats = {
    total: reports.length,
    pending: reports.filter((r) => r.status === "pending").length,
    reviewed: reports.filter((r) => r.status === "reviewed").length,
    resolved: reports.filter((r) => r.status === "resolved").length,
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] pb-[100px] text-[#FEFBE0] shadow-[0_0_40px_rgba(0,0,0,0.5)] overflow-x-hidden">
        <div className="px-6 pt-12">
          {/* Top Bar */}
          <div className="flex items-center justify-between mb-8">
            <Link
              to="/home"
              className="w-10 h-10 rounded-full bg-white/10 border border-white/20 flex items-center justify-center transition-colors hover:bg-white/20"
            >
              <ArrowLeft className="w-5 h-5 text-white" />
            </Link>
            <h1 className="text-xl font-bold font-['Playfair_Display',serif]">
              Damage Reports
            </h1>
            <div className="w-10 h-10 rounded-full bg-white/10 border border-white/20 flex items-center justify-center relative">
              <Bell className="w-5 h-5 text-white" />
              {stats.pending > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 bg-[#E76F51] rounded-full text-[10px] font-bold flex items-center justify-center">
                  {stats.pending}
                </span>
              )}
            </div>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-4 gap-2 mb-6">
            <div className="bg-white/5 border border-white/10 rounded-xl p-3 text-center">
              <span className="text-lg font-bold text-white block">{stats.total}</span>
              <span className="text-[9px] font-bold text-white/40 uppercase tracking-widest">
                Total
              </span>
            </div>
            <div className="bg-[#F4A261]/5 border border-[#F4A261]/20 rounded-xl p-3 text-center">
              <span className="text-lg font-bold text-[#F4A261] block">{stats.pending}</span>
              <span className="text-[9px] font-bold text-[#F4A261]/60 uppercase tracking-widest">
                Pending
              </span>
            </div>
            <div className="bg-[#52B788]/5 border border-[#52B788]/20 rounded-xl p-3 text-center">
              <span className="text-lg font-bold text-[#52B788] block">{stats.reviewed}</span>
              <span className="text-[9px] font-bold text-[#52B788]/60 uppercase tracking-widest">
                Reviewed
              </span>
            </div>
            <div className="bg-[#A8DADC]/5 border border-[#A8DADC]/20 rounded-xl p-3 text-center">
              <span className="text-lg font-bold text-[#A8DADC] block">{stats.resolved}</span>
              <span className="text-[9px] font-bold text-[#A8DADC]/60 uppercase tracking-widest">
                Resolved
              </span>
            </div>
          </div>

          {/* Filter Bar */}
          <div className="flex items-center gap-2 mb-6">
            <Filter className="w-4 h-4 text-white/40" />
            <div className="flex gap-1 flex-1 overflow-x-auto hide-scrollbar">
              {["all", "pending", "reviewed", "resolved", "rejected"].map((status) => (
                <button
                  key={status}
                  onClick={() => setFilterStatus(status)}
                  className={`px-3 py-1.5 rounded-full text-[10px] font-bold uppercase tracking-widest whitespace-nowrap transition-colors ${
                    filterStatus === status
                      ? "bg-[#F4A261] text-[#100E0A]"
                      : "bg-white/5 text-white/40 border border-white/10 hover:bg-white/10"
                  }`}
                >
                  {status}
                </button>
              ))}
            </div>
            <button
              onClick={fetchReports}
              className="w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center hover:bg-white/10 transition-colors"
            >
              <RefreshCw className={`w-4 h-4 text-white/60 ${loading ? "animate-spin" : ""}`} />
            </button>
          </div>

          {/* Reports List */}
          {loading ? (
            <div className="flex flex-col items-center justify-center py-20">
              <RefreshCw className="w-8 h-8 text-[#F4A261] animate-spin mb-4" />
              <span className="text-sm text-white/40">Loading reports...</span>
            </div>
          ) : reports.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <AlertTriangle className="w-12 h-12 text-white/20 mb-4" />
              <span className="text-sm text-white/40">No damage reports found</span>
            </div>
          ) : (
            <div className="space-y-3">
              {reports.map((report) => {
                const statusInfo = statusConfig[report.status] || statusConfig.pending;
                const StatusIcon = statusInfo.icon;
                return (
                  <div
                    key={report.id}
                    className="bg-white/5 border border-white/10 rounded-2xl p-4 transition-colors hover:bg-white/8"
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs font-bold text-[#F4A261]">
                            {report.damage_type}
                          </span>
                        </div>
                        <span className="text-[10px] text-white/30 block">
                          {new Date(report.created_at).toLocaleDateString("en-US", {
                            month: "short",
                            day: "numeric",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </span>
                      </div>
                      <div
                        className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full border ${statusInfo.bg}`}
                      >
                        <StatusIcon className={`w-3 h-3 ${statusInfo.color}`} />
                        <span className={`text-[10px] font-bold ${statusInfo.color}`}>
                          {statusInfo.label}
                        </span>
                      </div>
                    </div>

                    <p className="text-sm text-white/70 mb-3 leading-relaxed">
                      {report.details}
                    </p>

                    <div className="flex items-center justify-between">
                      <span className="text-[10px] text-white/30">
                        {report.location || "Unknown location"}
                      </span>

                      {report.status === "pending" && (
                        <div className="flex gap-2">
                          <button
                            onClick={() => updateStatus(report.id, "rejected")}
                            disabled={updatingId === report.id}
                            className="px-3 py-1.5 rounded-full bg-[#E76F51]/10 border border-[#E76F51]/30 text-[#E76F51] text-[10px] font-bold uppercase tracking-widest transition-colors hover:bg-[#E76F51]/20 disabled:opacity-50"
                          >
                            Reject
                          </button>
                          <button
                            onClick={() => updateStatus(report.id, "reviewed")}
                            disabled={updatingId === report.id}
                            className="px-3 py-1.5 rounded-full bg-[#52B788]/10 border border-[#52B788]/30 text-[#52B788] text-[10px] font-bold uppercase tracking-widest transition-colors hover:bg-[#52B788]/20 disabled:opacity-50"
                          >
                            Review
                          </button>
                        </div>
                      )}

                      {report.status === "reviewed" && (
                        <button
                          onClick={() => updateStatus(report.id, "resolved")}
                          disabled={updatingId === report.id}
                          className="px-3 py-1.5 rounded-full bg-[#A8DADC]/10 border border-[#A8DADC]/30 text-[#A8DADC] text-[10px] font-bold uppercase tracking-widest transition-colors hover:bg-[#A8DADC]/20 disabled:opacity-50"
                        >
                          Resolve
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        <BottomNav />
      </div>
    </div>
  );
}
