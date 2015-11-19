package org.fao.geonet.schema.iso19139mcp20;

import org.jdom.Namespace;

/**
 * Namespaces for iso19139.mcp-2.0 metadata standard.
 */
public class ISO19139MCP20Namespaces {
    public static final Namespace MCP =
            Namespace.getNamespace("mcp", "http://schemas.aodn.org.au/mcp-2.0");
    public static final Namespace GCO =
            Namespace.getNamespace("gco", "http://www.isotc211.org/2005/gco");
    public static final Namespace SRV =
            Namespace.getNamespace("srv", "http://www.isotc211.org/2005/srv");
    public static final Namespace GMD =
            Namespace.getNamespace("gmd", "http://www.isotc211.org/2005/gmd");
    public static final Namespace GMX =
            Namespace.getNamespace("gmx", "http://www.isotc211.org/2005/gmx");
}
