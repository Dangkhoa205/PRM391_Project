import { ArrowRight } from "lucide-react";
import { Link, Navigate, useParams } from "react-router-dom";
import { Breadcrumb } from "@/components/Breadcrumb";
import { getPolicy, policies } from "@/data/policies";
import { paths } from "@/lib/paths";

export function PolicyPage() {
  const { slug } = useParams();
  const doc = getPolicy(slug);

  if (!doc) {
    return <Navigate to={paths.policy("doi-tra")} replace />;
  }

  return (
    <article className="bg-sand-50 pt-24 pb-20">
      <div className="mx-auto max-w-3xl px-4 sm:px-6">
        <Breadcrumb
          items={[
            { label: "Trang chủ", to: paths.home },
            { label: "Chính sách", to: paths.policy("doi-tra") },
            { label: doc.title },
          ]}
        />

        <p className="mt-5 text-[11px] font-bold uppercase tracking-[0.25em] text-clay-500">
          {doc.eyebrow}
        </p>
        <h1 className="mt-2 font-display text-3xl font-bold leading-tight text-ink sm:text-4xl">
          {doc.title}
        </h1>
        <p className="mt-3 text-sm leading-relaxed text-mute">{doc.summary}</p>
        <p className="mt-2 text-[11px] text-mute">Cập nhật {doc.updated}</p>

        <div className="mt-8 space-y-7">
          {doc.sections.map((section) => (
            <section key={section.heading} className="rounded-2xl border border-sand-200 bg-white p-5 sm:p-6">
              <h2 className="font-display text-xl font-bold text-ink">{section.heading}</h2>
              <ul className="mt-3 space-y-2">
                {section.body.map((line) => (
                  <li key={line} className="text-sm leading-relaxed text-mute pl-3.5 relative">
                    <span className="absolute left-0 top-2 h-1.5 w-1.5 rounded-full bg-clay-400" />
                    {line}
                  </li>
                ))}
              </ul>
            </section>
          ))}
        </div>

        <nav className="mt-10 border-t border-sand-200 pt-6">
          <p className="text-[11px] font-bold uppercase tracking-wider text-mute">Các chính sách khác</p>
          <ul className="mt-3 grid gap-2 sm:grid-cols-2">
            {policies
              .filter((p) => p.slug !== doc.slug)
              .map((p) => (
                <li key={p.slug}>
                  <Link
                    to={paths.policy(p.slug)}
                    className="flex items-center justify-between rounded-xl border border-sand-200 bg-white px-4 py-3 text-xs font-bold text-ink transition hover:border-clay-300 hover:text-clay-700"
                  >
                    <span>{p.title}</span>
                    <ArrowRight className="h-3.5 w-3.5 shrink-0" />
                  </Link>
                </li>
              ))}
          </ul>
        </nav>
      </div>
    </article>
  );
}
