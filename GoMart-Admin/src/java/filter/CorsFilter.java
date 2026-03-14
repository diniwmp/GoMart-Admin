package filter;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.container.PreMatching;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

@Provider
@PreMatching
public class CorsFilter implements ContainerRequestFilter,
                                    ContainerResponseFilter {

    @Override
    public void filter(ContainerRequestContext requestContext) {
        if (requestContext.getMethod().equals("OPTIONS")) {
            requestContext.abortWith(Response.ok().build());
        }
    }

    @Override
    public void filter(ContainerRequestContext requestContext,
                       ContainerResponseContext responseContext) {
        responseContext.getHeaders()
                .add("Access-Control-Allow-Origin", "*");
        responseContext.getHeaders()
                .add("Access-Control-Allow-Methods",
                        "GET, POST, PUT, DELETE, OPTIONS");
        responseContext.getHeaders()
                .add("Access-Control-Allow-Headers",
                        "Content-Type, Authorization");
    }
}