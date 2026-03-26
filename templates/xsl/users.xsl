<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <table>
            <thead>
                <tr>
                    <th>Usuario</th>
                    <th>Rol</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="federacion/usuarios/usuario">
                    <tr>
                        <td>
                            <xsl:value-of select="user"/>
                        </td>
                        <td>
                            <xsl:value-of select="rol"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
            <tfooter>
                <tr>
                    <td colspan="2">
                        Total Usuarios: <xsl:value-of select="count(federacion/usuarios/usuario)"/>
                    </td>
                </tr>
            </tfooter>
        </table>

    </xsl:template>

</xsl:stylesheet>